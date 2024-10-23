import axios from 'axios';

// Check if we're in production mode
const isProd = import.meta.env.PROD;

// Use environment variable in production, localhost in development
const ENV_URL = isProd ? import.meta.env.VITE_API_URL : 'http://localhost:4000';

const api = axios.create({
  baseURL: `${ENV_URL}/api`
});

api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response && error.response.status === 401) {
      localStorage.removeItem('token');
      localStorage.removeItem('role');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

export default api;