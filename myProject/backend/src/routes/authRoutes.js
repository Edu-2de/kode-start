import { Router } from 'express';
const router = Router();
import { register, login, getProfile, logout } from '../controllers/authController.js';
import authMiddleware from '../middleware/authMiddleware.js';

// Public routes
router.post('/register', register);
router.post('/login', login);

// Protected routes
router.get('/profile', authMiddleware, getProfile);
router.post('/logout', authMiddleware, logout);

export default router;
