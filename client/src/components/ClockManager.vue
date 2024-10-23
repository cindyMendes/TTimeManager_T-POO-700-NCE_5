<template>
  <div class="bg-bat-gray rounded-lg shadow-bat p-6" role="region" aria-labelledby="time-tracker-title">
    <h2 id="time-tracker-title" class="text-2xl font-bold mb-6 text-bat-yellow">Gotham Time Tracker</h2>
    
    <div class="mb-6" aria-live="polite">
      <p v-if="isClockedIn" class="text-bat-blue font-semibold">
        Vigilance active depuis : <span class="text-bat-yellow">{{ startTime }}</span>
      </p>
      <p v-else-if="endTime" class="text-bat-silver">
        Patrouille terminée à : <span class="text-bat-yellow">{{ endTime }}</span>
      </p>
    </div>

    <button
      @click="toggleClock"
      :disabled="loading"
      :aria-busy="loading"
      :class="[
        'bat-button w-full mb-4',
        isClockedIn ? 'bat-button-red' : 'bat-button-yellow',
        loading ? 'opacity-50 cursor-not-allowed' : ''
      ]"
    >
      <span v-if="loading" class="inline-flex items-center">
        <svg class="animate-spin -ml-1 mr-3 h-5 w-5" fill="none" viewBox="0 0 24 24">
          <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
          <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
        </svg>
        Traitement...
      </span>
      <span v-else>
        {{ isClockedIn ? 'Terminer la patrouille' : 'Débuter la patrouille' }}
      </span>
    </button>

    <button
      @click="refresh"
      :disabled="loading"
      :class="['bat-button bat-button-gray w-full', loading ? 'opacity-50 cursor-not-allowed' : '']"
    >
      Actualiser le statut
    </button>

    <!-- Error display -->
    <div v-if="error" class="mt-4 bg-red-900 text-bat-silver p-4 rounded-md" role="alert">
      {{ error }}
    </div>

    <!-- Status display -->
    <div v-if="lastClock" class="mt-6">
      <h3 class="text-xl font-bold mb-4 text-bat-yellow">État actuel de la patrouille</h3>
      <div class="bg-bat-black p-4 rounded-lg">
        <dl class="grid grid-cols-1 gap-4">
          <div>
            <dt class="text-bat-silver font-medium">Statut:</dt>
            <dd class="text-bat-yellow">{{ getStatusText }}</dd>
          </div>
          <div>
            <dt class="text-bat-silver font-medium">Dernier pointage:</dt>
            <dd class="text-bat-yellow">{{ formatDate(lastClock.time) }}</dd>
          </div>
          <div v-if="patrolDuration">
            <dt class="text-bat-silver font-medium">Durée de la patrouille:</dt>
            <dd class="text-bat-yellow">{{ patrolDuration }}</dd>
          </div>
        </dl>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, computed, onMounted, watch } from 'vue';
import { useRoute } from 'vue-router';
import api from '@/services/api_token';

export default {
  name: 'TimeTracker',
  
  setup() {
    const route = useRoute();
    const isClockedIn = ref(false);
    const startTime = ref(null);
    const endTime = ref(null);
    const loading = ref(false);
    const userId = ref(null);
    const error = ref(null);
    const lastClock = ref(null);
    const patrolId = ref(null);

    const getStatusText = computed(() => {
      if (!lastClock.value) return 'Aucune patrouille enregistrée';
      return lastClock.value.status ? 'Patrouille en cours' : 'Patrouille terminée';
    });

    const formatDate = (date) => {
      return new Date(date).toLocaleString('fr-FR', {
        year: 'numeric',
        month: 'long',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit'
      });
    };

    const refresh = async () => {
      if (!userId.value) {
        error.value = "Aucun utilisateur sélectionné";
        return;
      }

      loading.value = true;
      error.value = null;

      try {
        const response = await api.get(`/clocks/${userId.value}`);
        const clocks = response.data.data;

        if (clocks && clocks.length > 0) {
          lastClock.value = clocks[clocks.length - 1];
          isClockedIn.value = lastClock.value.status === true;
          
          if (isClockedIn.value) {
            startTime.value = formatDate(lastClock.value.time);
            endTime.value = null;
          } else {
            endTime.value = formatDate(lastClock.value.time);
          }
        } else {
          resetState();
        }
      } catch (err) {
        handleError(err, "lors de la récupération des données");
      } finally {
        loading.value = false;
      }
    };

    const toggleClock = async () => {
      if (!userId.value) {
        error.value = "Aucun utilisateur sélectionné";
        return;
      }

      loading.value = true;
      error.value = null;

      try {
        const newStatus = !isClockedIn.value;
        const currentTime = new Date().toISOString();

        const response = await api.post(`/clocks/${userId.value}`, {
          time: currentTime,
          status: newStatus
        });

        lastClock.value = response.data.data;
        isClockedIn.value = newStatus;
        
        if (newStatus) {
          startTime.value = formatDate(currentTime);
          endTime.value = null;
        } else {
          endTime.value = formatDate(currentTime);
        }

        await refresh(); // Refresh to get latest state
      } catch (err) {
        handleError(err, "lors du changement d'état");
      } finally {
        loading.value = false;
      }
    };

    const resetState = () => {
      lastClock.value = null;
      isClockedIn.value = false;
      startTime.value = null;
      endTime.value = null;
      patrolId.value = null;
    };

    const handleError = (error, context) => {
      console.error(`Erreur ${context}:`, error);
      if (error.response) {
        switch (error.response.status) {
          case 401:
            error.value = "Session expirée. Veuillez vous reconnecter.";
            setTimeout(() => window.location.href = '/login', 2000);
            break;
          case 403:
            error.value = "Accès non autorisé.";
            break;
          case 404:
            error.value = "Utilisateur non trouvé.";
            break;
          case 422:
            error.value = "Données invalides. Veuillez réessayer.";
            break;
          default:
            error.value = `Une erreur est survenue ${context}. Veuillez réessayer.`;
        }
      } else if (error.request) {
        error.value = "Impossible de contacter le serveur. Veuillez vérifier votre connexion.";
      } else {
        error.value = `Une erreur inattendue est survenue ${context}.`;
      }
    };

    const calculatePatrolDuration = () => {
      if (!startTime.value) return null;
      const start = new Date(startTime.value);
      const end = endTime.value ? new Date(endTime.value) : new Date();
      const diff = end - start;
      const hours = Math.floor(diff / 3600000);
      const minutes = Math.floor((diff % 3600000) / 60000);
      return `${hours}h ${minutes}m`;
    };

    onMounted(() => {
      userId.value = route.query.id;
      if (userId.value) {
        refresh();
      }
    });

    watch(() => route.query.id, (newId) => {
      userId.value = newId;
      if (userId.value) {
        refresh();
      } else {
        resetState();
      }
    });

    return {
      isClockedIn,
      startTime,
      endTime,
      loading,
      error,
      lastClock,
      patrolId,
      getStatusText,
      patrolDuration: computed(calculatePatrolDuration),
      formatDate,
      refresh,
      toggleClock
    };
  }
};
</script>

<style scoped>
.bat-button {
  @apply py-2 px-4 rounded-md transition-colors duration-200 font-medium focus:outline-none focus:ring-2 focus:ring-offset-2;
}

.bat-button-yellow {
  @apply bg-bat-yellow text-bat-black hover:bg-yellow-200 focus:ring-bat-yellow;
}

.bat-button-red {
  @apply bg-red-600 text-white hover:bg-red-700 focus:ring-red-500;
}

.bat-button-gray {
  @apply bg-bat-gray text-bat-silver hover:bg-opacity-90 focus:ring-bat-gray;
}
</style>