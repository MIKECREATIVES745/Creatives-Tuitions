import jwt from 'jsonwebtoken';
import { query } from './db.js';
export function signToken(user) { return jwt.sign({ id:user.id, role:user.role, email:user.email }, process.env.JWT_SECRET, { expiresIn:process.env.JWT_EXPIRES_IN || '8h' }); }
export async function auth(req,res,next) {
 try {
  const token = (req.headers.authorization || '').replace(/^Bearer\s+/i,'');
  if (!token) return res.status(401).json({error:'Authentication required'});
  const payload = jwt.verify(token, process.env.JWT_SECRET);
  const { rows } = await query('SELECT id,full_name,email,phone,role,active,must_change_password FROM users WHERE id=$1',[payload.id]);
  if (!rows[0] || !rows[0].active) return res.status(401).json({error:'Account unavailable'});
  req.user = rows[0]; next();
 } catch { return res.status(401).json({error:'Invalid or expired session'}); }
}
export const allow = (...roles) => (req,res,next) => roles.includes(req.user?.role) ? next() : res.status(403).json({error:'You do not have permission to perform this action'});
