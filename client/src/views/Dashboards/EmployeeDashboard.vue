<template>
  <div class="bg-bat-black min-h-screen p-6 text-bat-silver font-gotham">
    <header class="mb-8">
      <h1 class="text-3xl font-bold text-bat-yellow">Tableau de Bord du Vigilant</h1>
    </header>

    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      <!-- User Profile Card -->
      <div class="bg-bat-gray rounded-lg shadow-bat p-6 hover:bg-opacity-90 transition duration-300">
        <h2 class="text-xl font-bold mb-4 text-bat-yellow flex items-center">
          <i class="fas fa-user mr-2"></i> Profil du Vigilant
        </h2>
        <User />
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
          <i class="fas fa-calendar-alt mr-2"></i> Journal de Patrouille
        </h2>
        <WorkingTimes :userId="currentUserId" />
      </div>

      <!-- Chart Manager Card -->
      <div class="bg-bat-gray rounded-lg shadow-bat p-6 hover:bg-opacity-90 transition duration-300 col-span-1 md:col-span-2 lg:col-span-3">
        <h2 class="text-xl font-bold mb-4 text-bat-yellow flex items-center">
        </h2>
        <ChartManager :userId="currentUserId" />
      </div>

      <!-- Daily Hours Chart Card -->
      <div class="bg-bat-gray rounded-lg shadow-bat p-6 hover:bg-opacity-90 transition duration-300 col-span-1 md:col-span-2 lg:col-span-3">
        <h2 class="text-xl font-bold mb-4 text-bat-yellow flex items-center">
          <i class="fas fa-chart-line mr-2"></i> Heures Quotidiennes
        </h2>
        <DailyHoursChart :userId="currentUserId" />
      </div>

      <!-- Line Chart Card -->
      <div class="bg-bat-gray rounded-lg shadow-bat p-6 hover:bg-opacity-90 transition duration-300 col-span-1 md:col-span-2 lg:col-span-3">
        <h2 class="text-xl font-bold mb-4 text-bat-yellow flex items-center">
          <i class="fas fa-chart-line mr-2"></i> Activité de Patrouille
        </h2>
        <LineChart :userId="currentUserId" />
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

export default {
  name: 'EmployeeDashboard',
  components: {
    User,
    ClockManager,
    WorkingTimes,
    ChartManager,
    DailyHoursChart,
    LineChart
  },
  data() {
    return {
      currentUserId: '123' // Example user ID
    }
  }
}
</script>

<style scoped>
/* You can add any additional styles here if needed */
</style>