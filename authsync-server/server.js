const express = require('express');
const admin = require('firebase-admin');
const cors = require('cors');
const rateLimit = require('express-rate-limit');
const helmet = require('helmet');
const crypto = require('crypto');
const nodemailer = require('nodemailer');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Security middleware
app.use(helmet());
app.use(cors({
  origin: true,
  credentials: true
}));
app.use(express.json({ limit: '10mb' }));

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
  message: 'Too many requests from this IP, please try again later.'
});
app.use('/api/', limiter);

// Password reset specific rate limiting (more restrictive)
const passwordResetLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // limit each IP to 5 password reset requests per windowMs
  message: 'Too many password reset attempts, please try again later.'
});

// Initialize Firebase Admin SDK
try {
  const serviceAccount = process.env.FIREBASE_SERVICE_ACCOUNT_KEY 
    ? JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT_KEY)
    : require('./serviceAccountKey.json');

  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    projectId: process.env.FIREBASE_PROJECT_ID
  });

  console.log('Firebase Admin SDK initialized successfully');
} catch (error) {
  console.error('Error initializing Firebase Admin SDK:', error);
  process.exit(1);
}

// Email transporter setup
let emailTransporter;
try {
  emailTransporter = nodemailer.createTransport({
    service: process.env.EMAIL_SERVICE || 'gmail',
    auth: {
      user: process.env.EMAIL_USER,
      pass: process.env.EMAIL_PASS
    }
  });
  console.log('Email transporter initialized successfully');
} catch (error) {
  console.error('Email transporter initialization failed:', error);
}

// In-memory storage for reset tokens (use Redis in production)
const resetTokens = new Map();

// Cleanup expired tokens every 5 minutes
setInterval(() => {
  const now = Date.now();
  for (const [token, data] of resetTokens.entries()) {
    if (now > data.expiresAt) {
      resetTokens.delete(token);
    }
  }
}, 5 * 60 * 1000);

// Middleware to verify Firebase ID token
const verifyFirebaseToken = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ 
        error: 'Unauthorized', 
        message: 'Missing or invalid authorization header' 
      });
    }

    const idToken = authHeader.split('Bearer ')[1];
    const decodedToken = await admin.auth().verifyIdToken(idToken);
    req.user = decodedToken;
    next();
  } catch (error) {
    console.error('Token verification error:', error);
    res.status(401).json({ 
      error: 'Unauthorized', 
      message: 'Invalid or expired token' 
    });
  }
};

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    timestamp: new Date().toISOString(),
    service: 'Firebase Multi-Account Server'
  });
});

// Send password reset email endpoint
app.post('/api/sendPasswordReset', passwordResetLimiter, async (req, res) => {
  try {
    const { email } = req.body;

    // Validate input
    if (!email) {
      return res.status(400).json({
        error: 'Bad Request',
        message: 'Email is required'
      });
    }

    // Validate email format
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      return res.status(400).json({
        error: 'Bad Request',
        message: 'Invalid email format'
      });
    }

    // Check if user exists in Firebase
    let userRecord;
    try {
      userRecord = await admin.auth().getUserByEmail(email);
    } catch (error) {
      if (error.code === 'auth/user-not-found') {
        // Return success even if user doesn't exist (security measure)
        return res.json({
          success: true,
          message: 'If an account with this email exists, a reset link has been sent'
        });
      }
      throw error;
    }

    // Generate reset token
    const resetToken = crypto.randomBytes(32).toString('hex');
    const expiresAt = Date.now() + (30 * 60 * 1000); // 30 minutes

    // Store reset token
    resetTokens.set(resetToken, {
      email: email,
      uid: userRecord.uid,
      expiresAt: expiresAt,
      used: false
    });

    // Create deep link URL
    const deepLinkUrl = `${process.env.APP_SCHEME || 'myapp'}://forgot-password?token=${resetToken}`;

    // Email content
    const emailHtml = `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
          .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }
          .button { display: inline-block; background: #667eea; color: white; padding: 12px 30px; text-decoration: none; border-radius: 5px; margin: 20px 0; }
          .footer { text-align: center; margin-top: 20px; font-size: 12px; color: #666; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>Password Reset Request</h1>
          </div>
          <div class="content">
            <h2>Reset Your Password</h2>
            <p>We received a request to reset your password. Click the button below to set a new password:</p>
            
            <a href="${deepLinkUrl}" class="button">Reset Password</a>
            
            <p><strong>This link will expire in 30 minutes.</strong></p>
            
            <p>If the button doesn't work, copy and paste this link into your browser:</p>
            <p style="word-break: break-all; color: #667eea;">${deepLinkUrl}</p>
            
            <p>If you didn't request this password reset, please ignore this email. Your account remains secure.</p>
          </div>
          <div class="footer">
            <p>This email was sent from an automated system. Please do not reply.</p>
          </div>
        </div>
      </body>
      </html>
    `;

    // Send email
    if (emailTransporter) {
      await emailTransporter.sendMail({
        from: process.env.EMAIL_FROM || process.env.EMAIL_USER,
        to: email,
        subject: 'Password Reset Request',
        html: emailHtml
      });
    }

    console.log(`Password reset email sent to: ${email} at ${new Date().toISOString()}`);

    res.json({
      success: true,
      message: 'If an account with this email exists, a reset link has been sent'
    });

  } catch (error) {
    console.error('Error sending password reset email:', error);
    res.status(500).json({
      error: 'Internal Server Error',
      message: 'Failed to send password reset email',
      details: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// Verify reset token endpoint
app.post('/api/verifyResetToken', async (req, res) => {
  try {
    const { token } = req.body;

    if (!token) {
      return res.status(400).json({
        error: 'Bad Request',
        message: 'Reset token is required'
      });
    }

    const tokenData = resetTokens.get(token);

    if (!tokenData) {
      return res.status(400).json({
        error: 'Invalid Token',
        message: 'Reset token is invalid or expired'
      });
    }

    if (Date.now() > tokenData.expiresAt) {
      resetTokens.delete(token);
      return res.status(400).json({
        error: 'Expired Token',
        message: 'Reset token has expired'
      });
    }

    if (tokenData.used) {
      return res.status(400).json({
        error: 'Used Token',
        message: 'Reset token has already been used'
      });
    }

    res.json({
      success: true,
      email: tokenData.email,
      message: 'Token is valid'
    });

  } catch (error) {
    console.error('Error verifying reset token:', error);
    res.status(500).json({
      error: 'Internal Server Error',
      message: 'Failed to verify reset token'
    });
  }
});

// Reset password endpoint
app.post('/api/resetPassword', async (req, res) => {
  try {
    const { token, newPassword } = req.body;

    // Validate input
    if (!token || !newPassword) {
      return res.status(400).json({
        error: 'Bad Request',
        message: 'Reset token and new password are required'
      });
    }

    // Validate password strength
    if (newPassword.length < 6) {
      return res.status(400).json({
        error: 'Weak Password',
        message: 'Password must be at least 6 characters long'
      });
    }

    const tokenData = resetTokens.get(token);

    if (!tokenData) {
      return res.status(400).json({
        error: 'Invalid Token',
        message: 'Reset token is invalid or expired'
      });
    }

    if (Date.now() > tokenData.expiresAt) {
      resetTokens.delete(token);
      return res.status(400).json({
        error: 'Expired Token',
        message: 'Reset token has expired'
      });
    }

    if (tokenData.used) {
      return res.status(400).json({
        error: 'Used Token',
        message: 'Reset token has already been used'
      });
    }

    // Update password in Firebase
    await admin.auth().updateUser(tokenData.uid, {
      password: newPassword
    });

    // Mark token as used
    tokenData.used = true;
    resetTokens.set(token, tokenData);

    console.log(`Password reset completed for user: ${tokenData.uid} at ${new Date().toISOString()}`);

    res.json({
      success: true,
      message: 'Password has been reset successfully'
    });

  } catch (error) {
    console.error('Error resetting password:', error);
    res.status(500).json({
      error: 'Internal Server Error',
      message: 'Failed to reset password',
      details: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// Generate custom token endpoint (existing account switching logic)
app.post('/api/generateCustomToken', verifyFirebaseToken, async (req, res) => {
  try {
    const { uid } = req.body;
    const requestingUser = req.user;

    // Validate input
    if (!uid) {
      return res.status(400).json({ 
        error: 'Bad Request', 
        message: 'UID is required' 
      });
    }

    // Security check: ensure requesting user owns the UID
    if (requestingUser.uid !== uid) {
      return res.status(403).json({ 
        error: 'Forbidden', 
        message: 'You do not have permission to request a custom token for this UID' 
      });
    }

    // Generate custom token
    const customToken = await admin.auth().createCustomToken(uid);

    // Log successful token generation (without exposing the token)
    console.log(`Custom token generated for user: ${uid} at ${new Date().toISOString()}`);

    res.json({ 
      success: true,
      customToken,
      expiresIn: '1h'
    });

  } catch (error) {
    console.error('Error generating custom token:', error);
    res.status(500).json({ 
      error: 'Internal Server Error', 
      message: 'Failed to generate custom token',
      details: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// Get user profile endpoint (existing account switching logic)
app.get('/api/userProfile/:uid', verifyFirebaseToken, async (req, res) => {
  try {
    const { uid } = req.params;
    const requestingUser = req.user;

    // Security check: ensure requesting user owns the UID or is admin
    if (requestingUser.uid !== uid && !requestingUser.admin) {
      return res.status(403).json({ 
        error: 'Forbidden', 
        message: 'Access denied' 
      });
    }

    const userRecord = await admin.auth().getUser(uid);
    
    res.json({
      success: true,
      user: {
        uid: userRecord.uid,
        email: userRecord.email,
        displayName: userRecord.displayName,
        photoURL: userRecord.photoURL,
        emailVerified: userRecord.emailVerified,
        creationTime: userRecord.metadata.creationTime,
        lastSignInTime: userRecord.metadata.lastSignInTime
      }
    });

  } catch (error) {
    console.error('Error fetching user profile:', error);
    res.status(500).json({ 
      error: 'Internal Server Error', 
      message: 'Failed to fetch user profile' 
    });
  }
});

// Validate custom token endpoint (existing logic)
app.post('/api/validateToken', async (req, res) => {
  try {
    const { customToken } = req.body;

    if (!customToken) {
      return res.status(400).json({ 
        error: 'Bad Request', 
        message: 'Custom token is required' 
      });
    }

    // This would typically be done on the client side
    // This endpoint is mainly for debugging purposes
    res.json({ 
      success: true,
      message: 'Token format appears valid',
      note: 'Actual validation should be done by Firebase Auth on client side'
    });

  } catch (error) {
    console.error('Error validating token:', error);
    res.status(500).json({ 
      error: 'Internal Server Error', 
      message: 'Failed to validate token' 
    });
  }
});

// Error handling middleware
app.use((error, req, res, next) => {
  console.error('Unhandled error:', error);
  res.status(500).json({ 
    error: 'Internal Server Error', 
    message: 'Something went wrong!' 
  });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({ 
    error: 'Not Found', 
    message: 'Endpoint not found' 
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
  console.log(`Health check: http://localhost:${PORT}/health`);
  console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down gracefully');
  process.exit(0);
});

process.on('SIGINT', () => {
  console.log('SIGINT received, shutting down gracefully');
  process.exit(0);
});