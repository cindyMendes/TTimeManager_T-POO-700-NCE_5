import axios from 'axios';

console.log('VUE_APP_API_URL:', process.env.VUE_APP_API_URL);

const apiClient = axios.create({
  baseURL: process.env.VUE_APP_API_URL || "http://elixir-backend:4000",
  headers: {
    'Content-Type': 'application/json'
  },
})

// Intercepteur pour ajouter le token JWT à chaque requête
apiClient.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) {
    config.headers['Authorization'] = `Bearer ${token}`;
  }
  return config;
}, (error) => {
  return Promise.reject(error);
});

export default {
  // Authentification
  login(credentials) {
    return apiClient.post('auth/login', credentials)
  },
  signup(userData) {
    return apiClient.post('auth/signup', userData)
  },

  // Users
  getCurrentUser() {
    return apiClient.get('users/profile')
  },
  listUsers(params = {}) {
    return apiClient.get('users', { params })
  },
  createUser(userData) {
    return apiClient.post('users', userData)
  },
  updateUser(id, userData) {
    return apiClient.put(`users/${id}`, userData)
  },
  deleteUser(id) {
    return apiClient.delete(`users/${id}`)
  },

  // Clocks (WorkingTimes)
  getClocks(userId) {
    return apiClient.get(`clocks/${userId}`)
  },
  postClock(userId, time, status) {
    return apiClient.post(`clocks/${userId}`, {
      time: time,
      status: status.toString()
    });
  },

  // WorkingTimes
  getWorkingTimes(userId, startDate, endDate) {
    return apiClient.get(`workingtimes/${userId}`, { params: { start: startDate, end: endDate } })
  },
  createWorkingTime(userId, workingTimeData) {
    return apiClient.post(`workingtime/${userId}`, workingTimeData)
  },
  updateWorkingTime(workingTimeId, workingTimeData) {
    return apiClient.put(`workingtime/${workingTimeId}`, workingTimeData)
  },
  deleteWorkingTime(workingTimeId) {
    return apiClient.delete(`workingtime/${workingTimeId}`)
  },

  // Reports
  getDailyHours(userId, date) {
    return apiClient.get(`reports/daily_hours`, { params: { user_id: userId, date: date } })
  },
  getWeeklyHours(userId, startDate, endDate) {
    return apiClient.get(`reports/weekly_hours`, { params: { user_id: userId, start_date: startDate, end_date: endDate } })
  },

  // Team Management (for managers)
  getTeamMembers(managerId) {
    return apiClient.get(`teams/${managerId}/members`)
  },
  addTeamMember(managerId, userId) {
    return apiClient.post(`teams/${managerId}/members`, { user_id: userId })
  },
  removeTeamMember(managerId, userId) {
    return apiClient.delete(`teams/${managerId}/members/${userId}`)
  },

  // General Manager functionalities
  promoteToManager(userId) {
    return apiClient.post(`users/${userId}/promote`)
  },
  getAllUserDashboards() {
    return apiClient.get('dashboards')
  },

  // Additional utilities
  setAuthToken(token) {
    localStorage.setItem('auth_token', token);
    apiClient.defaults.headers['Authorization'] = `Bearer ${token}`;
  },
  clearAuthToken() {
    localStorage.removeItem('auth_token');
    delete apiClient.defaults.headers['Authorization'];
  }
}