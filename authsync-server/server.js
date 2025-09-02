const express = require('express');
const admin = require('firebase-admin');
const cors = require('cors');
const rateLimit = require('express-rate-limit');
const helmet = require('helmet');
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