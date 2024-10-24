<!-- eslint-disable vue/multi-word-component-names -->
<template>
  <div class="relative min-h-screen w-full overflow-hidden">
    <!-- Background Image with Effects -->
    <div class="absolute inset-0">
      <!-- Static Background -->
      <div 
        class="absolute inset-0 bg-cover bg-center bg-no-repeat transition-opacity duration-700"
        :style="{ backgroundImage: `url(${backgroundImage})` }"
      ></div>
      
      <!-- Overlay with Dynamic Effects -->
      <div class="absolute inset-0 bg-gradient-to-b from-black/60 via-black/30 to-black/70">
        <!-- Subtle Fog Animation -->
        <div class="fog-overlay"></div>
      </div>
    </div>

    <!-- Main Content -->
    <div class="relative z-10 min-h-screen flex items-center justify-center px-4 sm:px-6 lg:px-8">
      <!-- Loading State -->
      <div v-if="isLoading" 
           class="flex flex-col items-center justify-center text-white">
        <div class="w-16 h-16 border-4 border-bat-yellow border-t-transparent rounded-full animate-spin mb-4 shadow-lg"></div>
        <span class="text-bat-silver text-lg font-medium">Chargement...</span>
      </div>

      <!-- Welcome Page -->
      <div v-else-if="!isAuthenticated" 
           class="welcome-page max-w-md w-full space-y-8 animate-fadeIn">
        <div class="text-center backdrop-blur-md bg-black/30 p-8 rounded-xl border border-white/10 shadow-2xl hover:bg-black/40 transition-all duration-300">
          <h1 class="text-4xl sm:text-5xl font-extrabold text-bat-yellow mb-6 tracking-tight glow-text">
            Bienvenue sur Gotham City Management
          </h1>
          <p class="text-bat-silver text-lg mb-8 font-medium">
            Connectez-vous pour accéder à votre tableau de bord.
          </p>
          <router-link 
            to="/login" 
            class="inline-flex items-center justify-center px-8 py-3 text-base font-medium rounded-md text-white bg-bat-blue hover:bg-bat-blue/90 transition-all duration-300 transform hover:scale-105 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-bat-yellow glow-button"
          >
            Se connecter
          </router-link>
        </div>
      </div>

      <!-- Dashboard Component -->
      <component 
        v-else 
        :is="currentDashboard" 
        :userId="userId"
        class="w-full max-w-7xl mx-auto"
      ></component>
    </div>
  </div>
</template>


<script setup>
import { ref, computed, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import EmployeeDashboard from '@/views/Dashboards/EmployeeDashboard.vue';
import ManagerDashboard from '@/views/Dashboards/ManagerDashboard.vue';
import GeneralManagerDashboard from '@/views/Dashboards/GeneralManagerDashboard.vue';
import AdminDashboard from '@/views/Dashboards/AdminDashboard.vue';
import { checkAuthentication } from '@/router/auth';
import backgroundImage from '@/assets/gotham.png';

const router = useRouter();
const isLoading = ref(true);
const isAuthenticated = ref(false);
const userRole = ref(null);
const userId = ref(null);

const currentDashboard = computed(() => {
  switch (userRole.value) {
    case 'employee':
      return EmployeeDashboard;
    case 'manager':
      return ManagerDashboard;
    case 'general_manager':
      return GeneralManagerDashboard;
    case 'admin':
      return AdminDashboard;
    default:
      return null;
  }
});

onMounted(async () => {
  try {
    // Simuler une vérification d'authentification et de récupération du rôle de l'utilisateur
    const authCheck = await checkAuthentication();
    isAuthenticated.value = authCheck.isAuthenticated;
    userRole.value = authCheck.role;
    userId.value = authCheck.userId;

    if (isAuthenticated.value && userRole.value === 'admin') {
      // Si l'utilisateur est un admin, rediriger directement vers le tableau de bord admin
      router.push('/admin-dashboard');
    }
  } catch (error) {
    console.error("Erreur lors de la vérification de l'authentification:", error);
  } finally {
    isLoading.value = false;
  }
});


</script>

<style scoped>
/* Fog Animation */
.fog-overlay {
  position: absolute;
  inset: 0;
  background: 
    repeating-linear-gradient(
      132deg,
      rgba(255, 255, 255, 0) 0%,
      rgba(255, 255, 255, 0.03) 50%,
      rgba(255, 255, 255, 0) 100%
    );
  background-size: 400% 400%;
  animation: fogMove 15s ease infinite;
  pointer-events: none;
}

/* Glowing Text Effect */
.glow-text {
  text-shadow: 
    0 0 10px rgba(255, 215, 0, 0.3),
    0 0 20px rgba(255, 215, 0, 0.2),
    0 0 30px rgba(255, 215, 0, 0.1);
}

/* Button Glow */
.glow-button {
  box-shadow: 0 0 15px rgba(59,130,246,0.3);
}

.glow-button:hover {
  box-shadow: 
    0 0 20px rgba(59,130,246,0.4),
    0 0 30px rgba(59,130,246,0.3);
}

@keyframes fogMove {
  0% {
    background-position: 0% 50%;
  }
  50% {
    background-position: 100% 50%;
  }
  100% {
    background-position: 0% 50%;
  }
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.animate-fadeIn {
  animation: fadeIn 0.6s ease-out;
}

/* Responsive Adjustments */
@media (max-width: 640px) {
  .welcome-page {
    margin: 0 1rem;
  }
  
  .glow-text {
    font-size: 2.5rem;
  }
}
</style>