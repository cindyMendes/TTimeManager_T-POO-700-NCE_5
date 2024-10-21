/* eslint-disable no-undef */
const isDevelopment = process.env.NODE_ENV === 'development';

export const API_URL = isDevelopment
  ? 'http://10.73.187.153:4000/api'  // URL de développement
  : 'https://api.timemanager.com/api';  // URL de production

// Vous pouvez également exporter isDevelopment si vous en avez besoin ailleurs
export { isDevelopment };