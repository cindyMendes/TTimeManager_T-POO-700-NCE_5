<template>
  <div>
    <!-- Error display -->
    <div v-if="error" class="mb-4 bg-red-900 text-bat-silver p-4 rounded-md">
      {{ error }}
    </div>

    <ul v-if="teams && teams.length">
      <li v-for="team in teams" :key="team.id" class="mb-4 p-4 bg-bat-gray rounded shadow-bat">
        <h3 class="text-xl font-bold mb-2 text-bat-yellow">{{ team.name }}</h3>
        <p class="text-sm text-bat-silver">Manager : {{ team.manager.username }}</p>

        <h4 class="mt-2 font-semibold text-bat-yellow">Membres:</h4>
        <ul class="ml-4 list-disc" v-if="team.members && team.members.length">
          <li v-for="member in team.members" :key="member.id" class="mt-1 flex items-center justify-between">
            <span class="text-bat-silver">{{ member.username }} ({{ member.email }})</span>
            <button @click="removeMemberFromTeam(team.id, member.id)" 
                    class="ml-2 bg-red-500 text-white p-1 rounded hover:bg-red-700"
                    :disabled="isLoading">
              Supprimer
            </button>
          </li>
        </ul>
        <p v-else class="text-bat-silver">Aucun membre trouvé pour cette équipe.</p>

        <div class="mt-4">
          <h5 class="font-semibold text-bat-yellow">Ajouter un membre</h5>
          <input
            v-model="newMemberId[team.id]"
            placeholder="ID Utilisateur"
            type="number"
            class="border p-2 rounded w-full mb-2 bg-bat-black text-bat-silver placeholder-bat-silver focus:outline-none focus:ring-bat-yellow focus:border-bat-yellow"
          />
          <div class="flex justify-center space-x-4">
            <button
              @click="addUserToTeam(team.id)"
              class="bg-bat-yellow text-bat-black p-2 rounded hover:bg-bat-yellow-light"
              :disabled="isLoading"
            >
              Ajouter un membre
            </button>
            <button
              @click="deleteTeam(team.id)"
              class="bg-red-500 text-bat-black p-2 rounded hover:bg-red-700"
              :disabled="isLoading"
            >
              Supprimer l'équipe
            </button>
          </div>
        </div>
      </li>
    </ul>

    <p v-else-if="!isLoading" class="text-bat-silver">Aucune équipe trouvée.</p>
    <p v-else class="text-bat-silver">Chargement des équipes...</p>

    <div class="mt-6">
      <h2 class="text-bat-yellow text-xl font-semibold mb-2">Créer une Team</h2>
      <form @submit.prevent="createTeam" class="bg-bat-gray p-4 rounded shadow">
        <div class="mb-4">
          <label class="block mb-2 text-bat-yellow">Nom de la team:</label>
          <input
            v-model="newTeam.name"
            type="text"
            class="border p-2 rounded w-full bg-bat-black text-bat-silver placeholder-bat-silver focus:outline-none focus:ring-bat-yellow focus:border-bat-yellow"
            required
          />
        </div>

        <div class="mb-4">
          <label class="block mb-2 text-bat-yellow">Manager ID :</label>
          <input
            v-model="newTeam.manager_id"
            type="number"
            class="border p-2 rounded w-full bg-bat-black text-bat-silver placeholder-bat-silver focus:outline-none focus:ring-bat-yellow focus:border-bat-yellow"
            required
          />
        </div>

        <button
          type="submit"
          class="bg-bat-yellow text-bat-black p-2 rounded hover:bg-bat-yellow-light"
          :disabled="isLoading"
        >
          Créer Team
        </button>
      </form>
    </div>
  </div>
</template>

<script>
import api from '@/services/api_token';

export default {
  name: 'Teams',
  data() {
    return {
      teams: [],
      newTeam: {
        name: "",
        manager_id: "",
      },
      newMemberId: {},
      error: null,
      isLoading: false
    };
  },

  mounted() {
    this.fetchTeams();
  },

  methods: {
    async fetchTeams() {
      this.isLoading = true;
      this.error = null;
      try {
        const response = await api.get('/teams');
        this.teams = response.data.data || response.data;
      } catch (error) {
        this.handleError(error, "lors de la récupération des équipes");
      } finally {
        this.isLoading = false;
      }
    },

    async createTeam() {
      this.isLoading = true;
      this.error = null;
      try {
        await api.post('/teams', { team: this.newTeam });
        await this.fetchTeams();
        this.newTeam.name = "";
        this.newTeam.manager_id = "";
      } catch (error) {
        this.handleError(error, "lors de la création de l'équipe");
      } finally {
        this.isLoading = false;
      }
    },

    async addUserToTeam(teamId) {
      const userId = this.newMemberId[teamId];
      if (!userId) {
        this.error = "Veuillez entrer un ID utilisateur";
        return;
      }

      this.isLoading = true;
      this.error = null;
      try {
        await api.put(`/teams/${teamId}/users/${userId}`);
        await this.fetchTeams();
        this.newMemberId[teamId] = "";
      } catch (error) {
        this.handleError(error, "lors de l'ajout du membre");
      } finally {
        this.isLoading = false;
      }
    },

    async deleteTeam(teamId) {
      if (!confirm("Êtes-vous sûr de vouloir supprimer cette équipe ?")) {
        return;
      }

      this.isLoading = true;
      this.error = null;
      try {
        await api.delete(`/teams/${teamId}`);
        await this.fetchTeams();
      } catch (error) {
        this.handleError(error, "lors de la suppression de l'équipe");
      } finally {
        this.isLoading = false;
      }
    },

    async removeMemberFromTeam(teamId, userId) {
      if (!confirm("Êtes-vous sûr de vouloir retirer ce membre de l'équipe ?")) {
        return;
      }

      this.isLoading = true;
      this.error = null;
      try {
        await api.delete(`/teams/${teamId}/members/${userId}`);
        await this.fetchTeams();
      } catch (error) {
        this.handleError(error, "lors du retrait du membre");
      } finally {
        this.isLoading = false;
      }
    },

    handleError(error, context) {
      console.error(`Erreur ${context}:`, error);
      if (error.response) {
        switch (error.response.status) {
          case 401:
            this.error = "Session expirée. Veuillez vous reconnecter.";
            setTimeout(() => {
              this.$router.push('/login');
            }, 2000);
            break;
          case 403:
            this.error = "Accès non autorisé.";
            break;
          case 404:
            this.error = "Ressource non trouvée.";
            break;
          case 422:
            this.error = "Données invalides. Veuillez vérifier vos informations.";
            break;
          default:
            this.error = `Une erreur est survenue ${context}. Veuillez réessayer.`;
        }
      } else if (error.request) {
        this.error = "Impossible de contacter le serveur. Veuillez vérifier votre connexion.";
      } else {
        this.error = `Une erreur inattendue est survenue ${context}.`;
      }

      // Clear error after 5 seconds
      setTimeout(() => {
        this.error = null;
      }, 5000);
    }
  }
};
</script>