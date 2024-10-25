<template>
  <div class="bg-bat-black min-h-screen p-6 text-bat-silver font-gotham">
    <header class="mb-8">
      <h1 class="text-3xl font-bold text-bat-yellow">Tableau de Bord du Maître de Gotham</h1>
    </header>

    <!-- Notifications Container -->
    <div class="fixed top-4 right-4 z-50 space-y-4">
      <div 
        v-if="notification.show"
        class="notification-slide-in bg-zinc-800/90 backdrop-blur-sm border rounded-lg shadow-2xl overflow-hidden"
        :class="{
          'border-green-400 bg-green-900/50': notification.type === 'success',
          'border-red-400 bg-red-900/50': notification.type === 'error'
        }"
      >
        <div class="px-4 py-3 flex items-start">
          <!-- Icon -->
          <div class="flex-shrink-0 mr-3">
            <svg 
              v-if="notification.type === 'success'"
              class="h-6 w-6 text-green-200" 
              fill="none" 
              viewBox="0 0 24 24" 
              stroke="currentColor"
            >
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
            </svg>
            <svg 
              v-else
              class="h-6 w-6 text-red-200" 
              fill="none" 
              viewBox="0 0 24 24" 
              stroke="currentColor"
            >
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </div>
          
          <!-- Content -->
          <div class="flex-1">
            <p class="font-bold" :class="{
              'text-green-200': notification.type === 'success',
              'text-red-200': notification.type === 'error'
            }">
              {{ notification.title }}
            </p>
            <p class="mt-1 text-sm" :class="{
              'text-green-200': notification.type === 'success',
              'text-red-200': notification.type === 'error'
            }">
              {{ notification.message }}
            </p>
          </div>
          
          <!-- Close Button -->
          <button 
            @click="dismissNotification"
            class="flex-shrink-0 ml-4 text-gray-400 hover:text-gray-200 transition-colors duration-200"
          >
            <svg class="h-4 w-4" fill="currentColor" viewBox="0 0 20 20">
              <path d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z"></path>
            </svg>
          </button>
        </div>
      </div>
    </div>

    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      <!-- General Manager Profile Card -->
      <div class="bg-bat-gray rounded-lg shadow-bat p-6 hover:bg-opacity-90 transition duration-300">
        <h2 class="text-xl font-bold mb-4 text-bat-yellow flex items-center">
          <i class="fas fa-user-tie mr-2"></i> Profil du Maître de Gotham
        </h2>
        <User />
      </div>

      <!-- Clock Manager Card -->
      <div class="bg-bat-gray rounded-lg shadow-bat p-6 hover:bg-opacity-90 transition duration-300">
        <h2 class="text-xl font-bold mb-4 text-bat-yellow flex items-center">
          <i class="fas fa-clock mr-2"></i> Tracker de Patrouille Personnel
        </h2>
        <ClockManager :userId="currentUserId" />
      </div>

      <!-- Team Organization Overview Card -->
      <div class="bg-bat-gray rounded-lg shadow-bat p-6 hover:bg-opacity-90 transition duration-300">
        <h2 class="text-xl font-bold mb-4 text-bat-yellow flex items-center">
          <i class="fas fa-building mr-2"></i> Organisation des Teams
        </h2>
        <TeamList />
      </div>

      <!-- User Management Card -->
      <div class="bg-bat-gray rounded-lg shadow-bat p-6 hover:bg-opacity-90 transition duration-300 col-span-1 md:col-span-2 lg:col-span-3">
        <h2 class="text-xl font-bold mb-4 text-bat-yellow flex items-center">
          <i class="fas fa-users-cog mr-2"></i> Réaffectation des Utilisateurs
        </h2>
        
        <!-- User Type Selection -->
        <select 
          v-model="selectedUserType" 
          @change="handleUserTypeChange"
          class="w-full p-2 mb-4 bg-bat-black text-bat-silver border border-bat-gray rounded focus:outline-none focus:border-bat-yellow"
        >
          <option value="employee">Employés</option>
          <option value="manager">Managers</option>
        </select>

        <!-- User Selection Dropdown -->
        <select 
          v-model="selectedUserId"
          class="w-full p-2 mb-4 bg-bat-black text-bat-silver border border-bat-gray rounded focus:outline-none focus:border-bat-yellow"
        >
          <option value="">Sélectionner un utilisateur</option>
          <option 
            v-for="user in filteredUsers" 
            :key="user.id" 
            :value="user.id"
          >
            {{ user.username }} ({{ user.role }})
          </option>
        </select>

        <!-- Action Buttons -->
        <div class="flex space-x-4 mt-4" v-if="selectedUser">
          <button
            v-if="selectedUser.role === 'employee'"
            @click="promoteUser(selectedUser)"
            class="bat-button bat-button-blue flex-1"
          >
            Promouvoir en Manager
          </button>
          
          <button
            v-if="selectedUser.role === 'manager'"
            @click="demoteUser(selectedUser)"
            class="bat-button bat-button-red flex-1"
          >
            Rétrograder en Employé
          </button>
        </div>
      </div>

      <!-- Selected User Working Times Card -->
      <div v-if="selectedUserId" class="bg-bat-gray rounded-lg shadow-bat p-6 hover:bg-opacity-90 transition duration-300 col-span-1 md:col-span-2 lg:col-span-3">
        <h2 class="text-xl font-bold mb-4 text-bat-yellow flex items-center">
          <i class="fas fa-calendar-alt mr-2"></i> Journal de Patrouille de l'Utilisateur
        </h2>
        <WorkingTimes :userId="selectedUserId" />
      </div>

      <!-- Selected User Chart Manager Card -->
      <div v-if="selectedUserId" class="bg-bat-gray rounded-lg shadow-bat p-6 hover:bg-opacity-90 transition duration-300 col-span-1 md:col-span-2 lg:col-span-3">
        <h2 class="text-xl font-bold mb-4 text-bat-yellow flex items-center">
          <i class="fas fa-chart-bar mr-2"></i> Analyse des Patrouilles de l'Utilisateur
        </h2>
        <ChartManager :userId="selectedUserId" />
      </div>

      <!-- Selected User Daily Hours Chart Card -->
      <div v-if="selectedUserId" class="bg-bat-gray rounded-lg shadow-bat p-6 hover:bg-opacity-90 transition duration-300 col-span-1 md:col-span-2 lg:col-span-3">
        <h2 class="text-xl font-bold mb-4 text-bat-yellow flex items-center">
          <i class="fas fa-chart-line mr-2"></i> Heures Quotidiennes de l'Utilisateur
        </h2>
        <DailyHoursChart :userId="selectedUserId" />
      </div>

      <!-- Selected User Line Chart Card -->
      <div v-if="selectedUserId" class="bg-bat-gray rounded-lg shadow-bat p-6 hover:bg-opacity-90 transition duration-300 col-span-1 md:col-span-2 lg:col-span-3">
        <h2 class="text-xl font-bold mb-4 text-bat-yellow flex items-center">
          <i class="fas fa-chart-line mr-2"></i> Activité de Patrouille de l'Utilisateur
        </h2>
        <LineChart :userId="selectedUserId" />
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
import TeamList from '@/components/TeamList.vue';
import api from '@/services/api_token';

export default {
  name: 'GeneralManagerDashboard',
  components: {
    User,
    ClockManager,
    WorkingTimes,
    ChartManager,
    DailyHoursChart,
    LineChart,
    TeamList
  },
  
  data() {
    return {
      selectedUserType: 'employee',
      selectedUserId: '',
      users: [],
      error: null,
      currentUserId: localStorage.getItem('userId'),
      notification: {
        show: false,
        type: 'success',
        title: '',
        message: '',
        timeout: null
      }
    };
  },

  computed: {
    filteredUsers() {
      return this.users.filter(user => user.role === this.selectedUserType);
    },
    selectedUser() {
      return this.users.find(user => user.id === this.selectedUserId);
    }
  },

  mounted() {
    this.getAllEmployeeManagerUsers();
  },

  methods: {
    async getAllEmployeeManagerUsers() {
      try {
        const response = await api.get('/management/users');
        this.users = response.data.users;
        console.log('Users:', this.users);
      } catch (error) {
        this.handleError(error, 'la récupération des utilisateurs');
      }
    },

    async promoteUser(user) {
      try {
        await api.put(`/users/${user.id}/promote`);
        await this.getAllEmployeeManagerUsers();
        this.selectedUserId = '';
        this.showNotification(
          'success',
          'Promotion Réussie',
          `${user.username} a été promu au rôle de manager.`
        );
      } catch (error) {
        this.showNotification(
          'error',
          'Erreur !',
          error.response?.data?.errors?.detail || "Une erreur s'est produite lors de la promotion."
        );
      }
    },

    async demoteUser(user) {
      try {
        await api.put(`/users/${user.id}/demote`);
        await this.getAllEmployeeManagerUsers();
        this.selectedUserId = '';
        this.showNotification(
          'success',
          'Rétrogradation Réussie',
          `${user.username} a été rétrogradé au rôle d'employé.`
        );
      } catch (error) {
        this.showNotification(
          'error',
          'Erreur !',
          error.response?.data?.errors?.detail || "Une erreur s'est produite lors de la rétrogradation."
        );
      }
    },

    handleUserTypeChange() {
      // Clear selected user when changing user type
      this.selectedUserId = '';
    },

    handleError(error, action) {
      if (error.response) {
        const status = error.response.status;
        if (status === 401) {
          this.error = 'Session expirée. Veuillez vous reconnecter.';
          setTimeout(() => {
            this.$router.push('/login');
          }, 2000);
        } else if (status === 403) {
          this.error = 'Accès non autorisé. Droits insuffisants.';
        } else {
          const message = error.response.data.errors?.detail || error.response.data.message || error.response.statusText;
          this.error = `Erreur lors de ${action}: ${message}`;
        }
      } else if (error.request) {
        this.error = `Pas de réponse du serveur lors de ${action}. Veuillez vérifier votre connexion.`;
      } else {
        this.error = `Erreur lors de ${action}: ${error.message}`;
      }

      setTimeout(() => {
        this.error = null;
      }, 5000);
    },

    showNotification(type, title, message) {
      // Clear any existing timeout
      if (this.notification.timeout) {
        clearTimeout(this.notification.timeout);
      }

      // Set new notification
      this.notification = {
        show: true,
        type,
        title,
        message,
        timeout: setTimeout(() => {
          this.dismissNotification();
        }, 5000)
      };
    },

    dismissNotification() {
      this.notification.show = false;
      if (this.notification.timeout) {
        clearTimeout(this.notification.timeout);
      }
    }

  }
};
</script>

<style scoped>
  /* Animation for notification */
  .notification-slide-in {
    animation: slideIn 0.5s ease-out;
  }

  @keyframes slideIn {
    from {
      transform: translateX(100%);
      opacity: 0;
    }
    to {
      transform: translateX(0);
      opacity: 1;
    }
  }

  @keyframes slideOut {
    from {
      transform: translateX(0);
      opacity: 1;
    }
    to {
      transform: translateX(100%);
      opacity: 0;
    }
  }

  .bat-button {
    @apply py-2 px-4 rounded-md text-sm font-medium transition duration-150 ease-in-out;
  }

  .bat-button-blue {
    @apply bg-blue-600 text-white hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2;
  }

  .bat-button-red {
    @apply bg-red-600 text-white hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-red-500 focus:ring-offset-2;
  }

  .bat-button-gray {
    @apply bg-gray-600 text-white hover:bg-gray-700 focus:outline-none focus:ring-2 focus:ring-gray-500 focus:ring-offset-2;
  }

  .bat-button-yellow {
    @apply bg-yellow-500 text-black hover:bg-yellow-600 focus:outline-none focus:ring-2 focus:ring-yellow-400 focus:ring-offset-2;
  }

  .bat-button:disabled {
    @apply opacity-50 cursor-not-allowed;
  }
</style>