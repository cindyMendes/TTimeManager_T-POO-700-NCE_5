<!-- eslint-disable vue/multi-word-component-names -->
<template>
    <div class="bg-bat-black min-h-screen p-4 md:p-8 font-gotham text-bat-silver">
      <header class="flex items-center justify-between mb-8">
        <img src="@/assets/pngegg.png" alt="Batman Logo" class="h-12 w-auto" />
        <h1 class="text-3xl md:text-4xl font-bold text-bat-yellow">Gotham City Management</h1>
      </header>
      
      <div class="grid grid-cols-12 gap-6">
        <!-- Sidebar - User Management and Clock Manager -->
        <aside class="col-span-12 lg:col-span-3 space-y-6">
          <!-- User Management Card -->
          <div class="bg-bat-gray rounded-lg shadow-bat p-6 hover:bg-opacity-90 transition duration-300">
            <h2 class="text-2xl font-bold mb-4 text-bat-yellow">Vigilante Profile</h2>
            <User />
          </div>
  
          <!-- Clock Manager Card -->
          <div class="bg-bat-gray rounded-lg shadow-bat p-6 hover:bg-opacity-90 transition duration-300">
            <h2 class="text-2xl font-bold mb-4 text-bat-yellow">Patrol Tracker</h2>
            <ClockManager />
          </div>
        </aside>
  
        <!-- Main Content Area -->
        <main class="col-span-12 lg:col-span-9 space-y-6">
          <!-- Quick Stats Row -->
          <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
            <div class="bg-bat-blue rounded-lg shadow-bat p-6 text-center">
              <h3 class="text-xl font-bold mb-2 text-bat-yellow">Total Patrol Hours</h3>
              <p class="text-3xl font-bold text-bat-silver">{{ totalPatrolHours }}</p>
            </div>
            <div class="bg-bat-blue rounded-lg shadow-bat p-6 text-center">
              <h3 class="text-xl font-bold mb-2 text-bat-yellow">Active Missions</h3>
              <p class="text-3xl font-bold text-bat-silver">{{ activeMissions }}</p>
            </div>
            <div class="bg-bat-blue rounded-lg shadow-bat p-6 text-center">
              <h3 class="text-xl font-bold mb-2 text-bat-yellow">Vigilance Score</h3>
              <p class="text-3xl font-bold text-bat-silver">{{ vigilanceScore }}</p>
            </div>
          </div>
  
          <!-- Charts Row -->
          <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <!-- Vigilante Analytics Card -->
            <div class="bg-bat-gray rounded-lg shadow-bat p-6 hover:bg-opacity-90 transition duration-300">
              <h2 class="text-2xl font-bold mb-4 text-bat-yellow">Patrol Time Distribution</h2>
              <ChartManager :userId="currentUserId" />
            </div>
  
            <!-- Daily Patrol Hours Card -->
            <div class="bg-bat-gray rounded-lg shadow-bat p-6 hover:bg-opacity-90 transition duration-300">
              <h2 class="text-2xl font-bold mb-4 text-bat-yellow">Weekly Patrol Activity</h2>
              <DailyHoursChart :userId="currentUserId" />
            </div>
          </div>
  
  
  
          <div class="bg-bat-gray rounded-lg shadow-bat p-6 hover:bg-opacity-90 transition duration-300">
              <h2 class="text-2xl font-bold mb-4 text-bat-yellow">Line Patrol Activity</h2>
              <LineChart :userId="currentUserId" />
            </div>
          
  
          <!-- Working Times Card -->
          <div class="bg-bat-gray rounded-lg shadow-bat p-6 hover:bg-opacity-90 transition duration-300">
            <h2 class="text-2xl font-bold mb-4 text-bat-yellow">Patrol Log</h2>
            <WorkingTimes />
          </div>
        </main>
      </div>
    </div>
  </template>
  
  <script setup>
  import { ref, onMounted } from 'vue';
  import ClockManager from '@/components/ClockManager.vue';
  import User from '@/components/User.vue';
  import WorkingTimes from '@/components/WorkingTimes.vue';
  import ChartManager from '@/components/ChartManager.vue';
  import DailyHoursChart from '@/components/charts/user/DailyHoursChart.vue';
  import LineChart from '@/components/LineChart.vue';
  
  const currentUserId = ref('15'); // Replace with actual user ID logic
  const totalPatrolHours = ref(0);
  const activeMissions = ref(0);
  const vigilanceScore = ref(0);
  
  onMounted(async () => {
    totalPatrolHours.value = await fetchTotalPatrolHours();
    activeMissions.value = await fetchActiveMissions();
    vigilanceScore.value = await calculateVigilanceScore();
  });
  
  // Placeholder functions for fetching data
  const fetchTotalPatrolHours = async () => {
    return Math.floor(Math.random() * 100) + 50;
  };
  
  const fetchActiveMissions = async () => {
    return Math.floor(Math.random() * 5) + 1;
  };
  
  const calculateVigilanceScore = async () => {
    return Math.floor(Math.random() * 50) + 50;
  };
  </script>
  
  <style>
  @import url('https://fonts.googleapis.com/css2?family=Roboto:wght@400;700&display=swap');
  
  body {
    font-family: 'Roboto', sans-serif; /* Fallback to Roboto if Gotham is not available */
  }
  
  /* Unified Button Styles */
  .bat-button {
    @apply font-bold py-2 px-4 rounded-full shadow-bat transition duration-300 ease-in-out;
  }
  
  .bat-button-yellow {
    @apply bg-bat-yellow text-bat-black hover:bg-opacity-80;
  }
  
  .bat-button-blue {
    @apply bg-bat-blue text-white hover:bg-opacity-80;
  }
  
  .bat-button-red {
    @apply bg-red-600 text-white hover:bg-opacity-80;
  }
  
  .bat-button-gray {
    @apply bg-bat-gray text-bat-silver hover:bg-opacity-80;
  }
  </style>