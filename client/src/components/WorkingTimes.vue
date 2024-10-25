<template>
  <!-- Same template code but with loading states on buttons -->
  <div class="bg-bat-gray rounded-lg shadow-bat p-6">
    <h2 class="text-2xl font-bold mb-6 text-bat-yellow">Journal de Patrouille de Gotham</h2>

    <!-- Loading indicator -->
    <div v-if="loading" class="text-center py-4">
      <div class="inline-block animate-spin rounded-full h-8 w-8 border-t-2 border-b-2 border-bat-yellow"></div>
      <p class="mt-2 text-bat-silver">Accès au Bat-Ordinateur en cours...</p>
    </div>

    <!-- Error message -->
    <div v-else-if="error" class="bg-red-900 border-l-4 border-bat-yellow text-bat-silver p-4 mb-4" role="alert">
      <p class="font-bold">Alerte</p>
      <p>{{ error }}</p>
    </div>

    <div v-else-if="workingTimes.length > 0" class="space-y-4">
      <div v-for="workingTime in workingTimes" :key="workingTime.id" class="bg-bat-black p-4 rounded-lg shadow-inner">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
          <div>
            <p class="text-bat-yellow font-semibold">ID de Mission :</p>
            <p class="text-bat-silver">{{ workingTime.id }}</p>
          </div>
          <div>
            <p class="text-bat-yellow font-semibold">ID du Vigilant :</p>
            <p class="text-bat-silver">{{ workingTime.user_id }}</p>
          </div>
          <div>
            <p class="text-bat-yellow font-semibold">Début de Patrouille :</p>
            <p class="text-bat-blue">{{ formatTimeForDisplay(workingTime.start) }}</p>
          </div>
          <div>
            <p class="text-bat-yellow font-semibold">Fin de Patrouille :</p>
            <p class="text-bat-blue">{{ formatTimeForDisplay(workingTime.end) }}</p>
          </div>
        </div>
        <div class="flex gap-2 mt-2">
          <button 
            @click="editWorkingTime(workingTime)" 
            class="bat-button bat-button-blue flex-1"
            :disabled="loading"
          >
            Modifier le Journal
          </button>
          <button 
            @click="confirmDelete(workingTime.id)" 
            class="bat-button bat-button-red flex-1"
            :disabled="loading"
          >
            Supprimer le Journal
          </button>
        </div>
      </div>
    </div>

    <div v-else class="text-center py-4 text-bat-silver">
      Aucun journal de patrouille trouvé. La nuit est calme.
    </div>

    <button 
      @click="showCreateForm" 
      class="bat-button bat-button-yellow w-full mt-4"
      :disabled="loading"
    >
      Créer un nouveau Journal
    </button>

    <!-- Create form -->
    <div v-if="createMode" class="mt-8 bg-bat-black p-6 rounded-lg shadow-bat">
      <h3 class="text-lg font-semibold mb-4 text-bat-yellow">
        Créer un Nouveau Journal de Patrouille
      </h3>
      <form @submit.prevent="handleCreate" class="space-y-4">
        <div>
          <label for="newStartTime" class="block text-sm font-medium text-bat-silver mb-1">Début de Patrouille :</label>
          <input 
            type="datetime-local" 
            id="newStartTime" 
            v-model="newWorkingTime.start" 
            required
            :disabled="loading"
            class="w-full px-3 py-2 bg-bat-gray border border-bat-silver rounded-md text-bat-silver focus:outline-none focus:border-bat-yellow" 
          />
        </div>
        <div>
          <label for="newEndTime" class="block text-sm font-medium text-bat-silver mb-1">Fin de Patrouille :</label>
          <input 
            type="datetime-local" 
            id="newEndTime" 
            v-model="newWorkingTime.end" 
            required
            :disabled="loading"
            class="w-full px-3 py-2 bg-bat-gray border border-bat-silver rounded-md text-bat-silver focus:outline-none focus:border-bat-yellow" 
          />
        </div>
        <div class="flex justify-end space-x-4">
          <button 
            type="button" 
            @click="cancelCreate" 
            class="bat-button bat-button-gray"
            :disabled="loading"
          >
            Annuler
          </button>
          <button 
            type="submit" 
            class="bat-button bat-button-yellow"
            :disabled="loading"
          >
            Créer le Journal
          </button>
        </div>
      </form>
    </div>

    <!-- Edit form -->
    <div v-if="editMode" class="mt-8 bg-bat-black p-6 rounded-lg shadow-bat">
      <h3 class="text-lg font-semibold mb-4 text-bat-yellow">
        Modifier le Journal de Patrouille
      </h3>
      <form @submit.prevent="handleUpdate" class="space-y-4">
        <div>
          <label for="editStartTime" class="block text-sm font-medium text-bat-silver mb-1">Début de Patrouille :</label>
          <input 
            type="datetime-local" 
            id="editStartTime" 
            v-model="editForm.start" 
            required
            :disabled="loading"
            class="w-full px-3 py-2 bg-bat-gray border border-bat-silver rounded-md text-bat-silver focus:outline-none focus:border-bat-yellow" 
          />
        </div>
        <div>
          <label for="editEndTime" class="block text-sm font-medium text-bat-silver mb-1">Fin de Patrouille :</label>
          <input 
            type="datetime-local" 
            id="editEndTime" 
            v-model="editForm.end" 
            required
            :disabled="loading"
            class="w-full px-3 py-2 bg-bat-gray border border-bat-silver rounded-md text-bat-silver focus:outline-none focus:border-bat-yellow" 
          />
        </div>
        <div class="flex justify-end space-x-4">
          <button 
            type="button" 
            @click="cancelEdit" 
            class="bat-button bat-button-gray"
            :disabled="loading"
          >
            Annuler
          </button>
          <button 
            type="submit" 
            class="bat-button bat-button-yellow"
            :disabled="loading"
          >
            Mettre à Jour le Journal
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script>
import { ref, onMounted, watch } from 'vue';
import { useRoute } from 'vue-router';
import api from '@/services/api_token';

export default {
  name: "WorkingTimes",
  props: {
    userId: {
      type: [String, Number],
      required: true,
    },
  },
  
  setup(props) {
    const route = useRoute();
    const workingTimes = ref([]);
    const loading = ref(true);
    const error = ref(null);
    const editMode = ref(false);
    const createMode = ref(false);
    // const userId = ref(null);

    const editForm = ref({
      id: null,
      start: "",
      end: "",
    });

    const newWorkingTime = ref({
      start: "",
      end: "",
    });

    const getWorkingTimes = async () => {
  if (!props.userId) {
    console.log("Aucun ID utilisateur fourni.");
    return;
  }

  loading.value = true;
  error.value = null;
  try {
    console.log(`Fetching working times for user ID: ${props.userId}`);
    const response = await api.get(`/workingtimes/${props.userId}/times`);
    console.log("API response:", response.data);
    workingTimes.value = response.data.data || [];
  } catch (err) {
    handleError(err, "lors de la récupération des journaux");
  } finally {
    loading.value = false;
  }
};

    const handleCreate = async () => {
      if (!validateTimes(newWorkingTime.value)) return;

      loading.value = true;
      error.value = null;
      try {
        const data = {
          working_time: {
            start: new Date(newWorkingTime.value.start).toISOString(),
            end: new Date(newWorkingTime.value.end).toISOString(),
          }
        };


        await api.post(`/workingtime/${props.userId}`, data);
        await getWorkingTimes();
        cancelCreate();
      } catch (err) {
        handleError(err, "lors de la création du journal");
      } finally {
        loading.value = false;
      }
    };

    const handleUpdate = async () => {
      if (!validateTimes(editForm.value)) return;

      loading.value = true;
      error.value = null;
      try {
        const data = {
          working_time: {
            start: new Date(editForm.value.start).toISOString(),
            end: new Date(editForm.value.end).toISOString(),
          }
        };

        await api.put(`/workingtimes/${editForm.value.id}`, data);
        await getWorkingTimes();
        cancelEdit();
      } catch (err) {
        handleError(err, "lors de la mise à jour du journal");
      } finally {
        loading.value = false;
      }
    };

    const confirmDelete = async (id) => {
      if (!confirm("Êtes-vous sûr de vouloir supprimer ce journal de patrouille ?")) {
        return;
      }

      loading.value = true;
      error.value = null;
      try {
        await api.delete(`/workingtimes/${id}`);
        workingTimes.value = workingTimes.value.filter(wt => wt.id !== id);
      } catch (err) {
        handleError(err, "lors de la suppression du journal");
      } finally {
        loading.value = false;
      }
    };

    const editWorkingTime = (workingTime) => {
      editForm.value = {
        id: workingTime.id,
        start: formatTimeForInput(workingTime.start),
        end: formatTimeForInput(workingTime.end),
      };
      editMode.value = true;
    };

    const showCreateForm = () => {
      createMode.value = true;
      newWorkingTime.value = { start: "", end: "" };
    };

    const cancelCreate = () => {
      createMode.value = false;
      newWorkingTime.value = { start: "", end: "" };
      error.value = null;
    };

    const cancelEdit = () => {
      editMode.value = false;
      editForm.value = { id: null, start: "", end: "" };
      error.value = null;
    };

    const validateTimes = (form) => {
      if (!form.start || !form.end) {
        error.value = "Les dates de début et de fin sont requises.";
        return false;
      }

      const start = new Date(form.start);
      const end = new Date(form.end);

      if (end <= start) {
        error.value = "La date de fin doit être postérieure à la date de début.";
        return false;
      }

      return true;
    };

    const formatTimeForInput = (dateString) => {
      const date = new Date(dateString);
      return date.toISOString().slice(0, 16);
    };

    const formatTimeForDisplay = (time) => {
      return new Date(time).toLocaleString('fr-FR', {
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit'
      });
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
            error.value = "Journal de patrouille non trouvé.";
            break;
          case 422:
            error.value = "Données invalides. Veuillez vérifier les informations.";
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

    onMounted(() => {
      if (props.userId) {
        getWorkingTimes();
      }
    });

    watch(() => props.userId, (newId) => {
      if (newId) {
        getWorkingTimes();
      }
    });

    return {
      workingTimes,
      loading,
      error,
      editMode,
      createMode,
      editForm,
      newWorkingTime,
      editWorkingTime,
      showCreateForm,
      handleCreate,
      handleUpdate,
      confirmDelete,
      cancelCreate,
      cancelEdit,
      formatTimeForDisplay,
      formatTimeForInput
    };
  }
};
</script>

<style scoped>
.bat-button {
  @apply py-2 px-4 rounded transition-colors duration-200 disabled:opacity-50 disabled:cursor-not-allowed;
}

.bat-button-yellow {
  @apply bg-bat-yellow text-bat-black hover:bg-yellow-200;
}

.bat-button-blue {
  @apply bg-blue-500 text-white hover:bg-blue-600;
}

.bat-button-red {
  @apply bg-red-500 text-white hover:bg-red-600;
}

.bat-button-gray {
  @apply bg-bat-gray text-bat-silver hover:bg-opacity-90;
}
</style>