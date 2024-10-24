<!-- eslint-disable vue/multi-word-component-names -->
<template>
  <div class="home">
    <div v-if="isLoading" class="loading-spinner">
      <!-- Ajoutez ici un indicateur de chargement -->
      Chargement...
    </div>
    <div v-else-if="!isAuthenticated" class="welcome-page">
      <h1 class="text-3xl font-bold text-bat-yellow mb-4">Bienvenue sur Gotham City Management</h1>
      <p class="text-bat-silver mb-4">Connectez-vous pour accéder à votre tableau de bord.</p>
      <router-link to="/login" class="bg-bat-blue text-white py-2 px-4 rounded hover:bg-opacity-80">
        Se connecter
      </router-link>
    </div>
    <component v-else :is="currentDashboard" :userId="userId"></component>
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