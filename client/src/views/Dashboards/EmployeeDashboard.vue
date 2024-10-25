<template>
  <div class="bg-bat-black min-h-screen p-6 text-bat-silver font-gotham">
    <header class="mb-8">
      <h1 class="text-3xl font-bold text-bat-yellow">Tableau de Bord du Vigilant</h1>
    </header>

    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6" v-if="username">
      <!-- User Profile Card -->
      <div class="bg-bat-gray rounded-lg shadow-bat p-6 hover:bg-opacity-90 transition duration-300">
        <h2 class="text-xl font-bold mb-4 text-bat-yellow flex items-center">
          <i class="fas fa-user mr-2"></i> Profil de {{ username }}
        </h2>
        <User :username="username" />
      </div>

      <!-- Clock Manager Card -->
      <div class="bg-bat-gray rounded-lg shadow-bat p-6 hover:bg-opacity-90 transition duration-300">
        <h2 class="text-xl font-bold mb-4 text-bat-yellow flex items-center">
          <i class="fas fa-clock mr-2"></i> Tracker de Patrouille
        </h2>
        <ClockManager :userId="currentUserId" />
      </div>

      <!-- Working Times Card -->
      <div class="bg-bat-gray rounded-lg shadow-bat p-6 hover:bg-opacity-90 transition duration-300">
        <h2 class="text-xl font-bold mb-4 text-bat-yellow flex items-center">
          <i class="fas fa-calendar-alt mr-2"></i> Journal de Patrouille de {{ username }}
        </h2>
        <WorkingTimes :userId="currentUserId" :username="username" />
      </div>

      <!-- Chart Manager Card -->
      <div class="bg-bat-gray rounded-lg shadow-bat p-6 hover:bg-opacity-90 transition duration-300">
        <h2 class="text-xl font-bold mb-4 text-bat-yellow flex items-center">
          <i class="fas fa-chart-bar mr-2"></i> Analyse de Patrouille
        </h2>
        <ChartManager :userId="currentUserId" :username="username" v-if="username" />
      </div>

      <!-- Daily Hours Chart Card -->
      <div class="bg-bat-gray rounded-lg shadow-bat p-6 hover:bg-opacity-90 transition duration-300">
        <h2 class="text-xl font-bold mb-4 text-bat-yellow flex items-center">
          <i class="fas fa-chart-line mr-2"></i> Heures Quotidiennes
        </h2>
        <DailyHoursChart :userId="currentUserId" :username="username" v-if="username" />
      </div>

      <!-- Line Chart Card -->
      <div class="bg-bat-gray rounded-lg shadow-bat p-6 hover:bg-opacity-90 transition duration-300">
        <h2 class="text-xl font-bold mb-4 text-bat-yellow flex items-center">
          <i class="fas fa-chart-line mr-2"></i> Activité de Patrouille
        </h2>
        <LineChart :userId="currentUserId" :username="username" v-if="username" />
      </div>
    </div>
  </div>
</template>


<script>
import User from '@/components/User.vue';
import ClockManager from '@/components/ClockManager.vue';
import WorkingTimes from '@/components/WorkingTimes.vue';
import ChartManager from '@/components/ChartManager.vue';
import DailyHoursChart from '@/components/charts/user/DailyHoursChart.vue';
import LineChart from '@/components/LineChart.vue';
import api from '@/services/api_token';

export default {
  name: 'EmployeeDashboard',
  components: {
    User,
    ClockManager,
    WorkingTimes,
    ChartManager,
    DailyHoursChart,
    LineChart,
  },
  data() {
    return {
      currentUserId: localStorage.getItem('userId') || '123', // Récupérer l'ID de l'utilisateur actuel
      username: '', // Nom de l'utilisateur actuel
    };
  },
  mounted() {
    this.fetchCurrentUserInfo();
  },
  methods: {
    async fetchCurrentUserInfo() {
      try {
        const response = await api.get(`/users/${this.currentUserId}`);
        this.username = response.data.data.username; // Utilisez data.data.username
      } catch (error) {
        console.error("Erreur lors de la récupération des informations de l'utilisateur :", error);
      }
    },
  },
};
</script>

<style scoped>
/* Styles additionnels si nécessaire */
</style>
