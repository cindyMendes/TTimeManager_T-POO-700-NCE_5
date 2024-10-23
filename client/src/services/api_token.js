import axios from 'axios';

const isDevelopment = !import.meta.env.PROD;
console.log('Current environment:', import.meta.env.MODE);
console.log('Is Production?', import.meta.env.PROD);
console.log('Is development?', isDevelopment);

const baseURL = isDevelopment 
  ? 'http://localhost:4000/api'
  : 'https://time-manager-backend-0d689d155ac3.herokuapp.com/api';

console.log('Using baseURL:', baseURL);

const api = axios.create({
  baseURL: baseURL
});

api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    console.log('Making request to:', config.baseURL + config.url);
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