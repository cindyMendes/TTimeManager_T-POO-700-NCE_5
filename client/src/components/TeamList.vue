<template>
  <div>
    <ul v-if="teams && teams.length">
      <li
        v-for="team in teams"
        :key="team.id"
        class="mb-4 p-4 bg-bat-gray rounded shadow-bat"
      >
        <h3 class="text-xl font-bold mb-2 text-bat-yellow">{{ team.name }}</h3>
        <p class="text-sm text-bat-silver">
          Manager : {{ team.manager.username }}
        </p>

        <h4 class="mt-2 font-semibold text-bat-yellow">Membres:</h4>
        <ul class="ml-4 list-disc" v-if="team.members && team.members.length">
          <li
            v-for="member in team.members"
            :key="member.id"
            class="mt-1 flex items-center justify-between"
          >
            <span class="text-bat-silver"
              >{{ member.username }} ({{ member.email }})</span
            >
            <button
              @click="removeMemberFromTeam(team.id, member.id)"
              class="ml-2 bg-red-500 text-white p-1 rounded hover:bg-red-700"
            >
              Supprimer
            </button>
          </li>
        </ul>
        <p v-else class="text-bat-silver">
          Aucun membre trouvé pour cette équipe.
        </p>

        <div class="mt-4">
  <h5 class="font-semibold text-bat-yellow">Ajouter un membre</h5>
  <input
    v-model="newMemberId[team.id]"
    placeholder="ID Utilisateur"
    type="number"
    class="border p-2 rounded w-full mb-2 bg-bat-black text-bat-silver placeholder-bat-silver focus:outline-none focus:ring-bat-yellow focus:border-bat-yellow"
  />
  <!-- Conteneur pour aligner les deux boutons sur la même ligne -->
  <div class="flex justify-center space-x-4">
    <button
      @click="addUserToTeam(team.id)"
      class="bg-bat-yellow text-bat-black p-2 rounded hover:bg-bat-yellow-light"
    >
      Ajouter un membre
    </button>
    <button
      @click="deleteTeam(team.id)"
      class="bg-red-500 text-bat-black p-2 rounded hover:bg-red-700"
    >
      Supprimer l'équipe
    </button>
  </div>
</div>
      </li>
    </ul>

    <p v-else class="text-bat-silver">Aucune équipe trouvée.</p>

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
        >
          Créer Team
        </button>
      </form>
    </div>
  </div>
</template>

<script>
import axios from "axios";

export default {
  data() {
    return {
      teams: [],
      newTeam: {
        name: "",
        manager_id: "",
      },
      newMemberId: {},
    };
  },
  mounted() {
    this.fetchTeams();
  },
  methods: {
    getAuthToken() {
      return localStorage.getItem("token");
    },
    setAuthHeader() {
      const token = this.getAuthToken();
      if (token) {
        axios.defaults.headers.common["Authorization"] = `Bearer ${token}`;
      } else {
        console.error("Token JWT non trouvé");
      }
    },
    fetchTeams() {
      this.setAuthHeader();
      axios
        .get("http://localhost:4000/api/teams")
        .then((response) => {
          this.teams = response.data.data || response.data;
          console.log("Response from API:", response);
        })
        .catch((error) => {
          console.error(
            "Error fetching teams:",
            error.response ? error.response.data : error
          );
        });
    },
    createTeam() {
      this.setAuthHeader();
      axios
        .post("http://localhost:4000/api/teams", { team: this.newTeam })
        .then(() => {
          this.fetchTeams();
          this.newTeam.name = "";
          this.newTeam.manager_id = "";
        })
        .catch((error) => {
          console.error(
            "Error creating team:",
            error.response ? error.response.data : error
          );
        });
    },
    addUserToTeam(teamId) {
      const userId = this.newMemberId[teamId];
      if (!userId) {
        alert("Please enter a user ID");
        return;
      }
      this.setAuthHeader();
      axios
        .put(`http://localhost:4000/api/teams/${teamId}/users/${userId}`)
        .then(() => {
          this.fetchTeams();
          this.newMemberId[teamId] = "";
        })
        .catch((error) => {
          console.error(
            "Error adding user to team:",
            error.response ? error.response.data : error
          );
        });
    },
    deleteTeam(teamId) {
      this.setAuthHeader();
      axios
        .delete(`http://localhost:4000/api/teams/${teamId}`)
        .then(() => {
          this.fetchTeams();
        })
        .catch((error) => {
          console.error(
            "Error deleting team:",
            error.response ? error.response.data : error
          );
        });
    },
    // Supprimer un membre d'une équipe
    removeMemberFromTeam(teamId, userId) {
      this.setAuthHeader(); // Ajouter le token JWT à chaque requête
      axios
        .delete(`http://localhost:4000/api/teams/${teamId}/members/${userId}`)
        .then(() => {
          this.fetchTeams(); // Recharger la liste des équipes après suppression du membre
        })
        .catch((error) => {
          console.error(
            "Error removing member from team:",
            error.response ? error.response.data : error
          );
        });
    },
  },
};
</script>
