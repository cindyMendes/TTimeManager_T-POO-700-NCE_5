<template>
    <div>
      <ul v-if="teams && teams.length">
        <li v-for="team in teams" :key="team.id" class="mb-4 p-4 bg-gray-200 rounded shadow">
          <h3 class="text-xl font-bold mb-2">{{ team.name }}</h3>
          <p class="text-sm text-gray-600">Managed by : {{ team.manager.username }}</p>
  
          <h4 class="mt-2 font-semibold">Members:</h4>
          <ul class="ml-4 list-disc" v-if="team.members && team.members.length">
  <li v-for="member in team.members" :key="member.id" class="mt-1 flex items-center justify-between">
    <span>{{ member.username }} ({{ member.email }})</span>
    <button 
      @click="removeMemberFromTeam(team.id, member.id)" 
      class="ml-2 bg-red-500 text-white p-1 rounded hover:bg-red-700">
      Remove
    </button>
  </li>
</ul>

          <p v-else>No members found for this team.</p>
  
          <div class="mt-4">
            <h5 class="font-semibold">Add a Member</h5>
            <input v-model="newMemberId[team.id]" placeholder="User ID" type="number" class="border p-2 rounded w-full mb-2" />
            <button @click="addUserToTeam(team.id)" class="bg-green-500 text-white p-2 rounded hover:bg-green-700">
              Add Member
            </button>
          </div>
  
          <button @click="deleteTeam(team.id)" class="mt-4 bg-red-500 text-white p-2 rounded hover:bg-red-700">
            Delete Team
          </button>
        </li>
      </ul>
  
      <p v-else class="text-gray-500">No teams found.</p>
  
      <div class="mt-6">
        <h2 class="text-bat-yellow text-xl font-semibold mb-2">Create a new team</h2>
        <form @submit.prevent="createTeam" class="bg-bat-gray p-4 rounded shadow">
          <div class="mb-4">
            <label class="block mb-2 text-bat-yellow">Team Name:</label>
            <input v-model="newTeam.name" type="text" class="border p-2 rounded w-full" required />
          </div>
  
          <div class="mb-4">
            <label class="block mb-2 text-bat-yellow">Manager ID:</label>
            <input v-model="newTeam.manager_id" type="number" class="border p-2 rounded w-full" required />
          </div>
  
          <button type="submit" class="bg-blue-500 text-white p-2 rounded hover:bg-blue-700">
            Create Team
          </button>
        </form>
      </div>
    </div>
  </template>
  
  <script>
  import axios from 'axios';
  
  export default {
    data() {
      return {
        teams: [], 
        newTeam: {
          name: '',
          manager_id: ''
        },
        newMemberId: {} 
      };
    },
    mounted() {
      this.fetchTeams();
    },
    methods: {
      getAuthToken() {
        return localStorage.getItem('token');
      },
      setAuthHeader() {
        const token = this.getAuthToken();
        if (token) {
          axios.defaults.headers.common['Authorization'] = `Bearer ${token}`;
        } else {
          console.error('Token JWT non trouvé');
        }
      },
      fetchTeams() {
        this.setAuthHeader();
        axios.get('http://localhost:4000/api/teams')
          .then(response => {
            this.teams = response.data.data || response.data; 
            console.log('Response from API:', response); 
          })
          .catch(error => {
            console.error('Error fetching teams:', error.response ? error.response.data : error);
          });
      },
      createTeam() {
        this.setAuthHeader();
        axios.post('http://localhost:4000/api/teams', { team: this.newTeam })
          .then(() => {
            this.fetchTeams();
            this.newTeam.name = '';
            this.newTeam.manager_id = '';
          })
          .catch(error => {
            console.error('Error creating team:', error.response ? error.response.data : error);
          });
      },
      addUserToTeam(teamId) {
        const userId = this.newMemberId[teamId];
        if (!userId) {
          alert('Please enter a user ID');
          return;
        }
        this.setAuthHeader();
        axios.put(`http://localhost:4000/api/teams/${teamId}/users/${userId}`)
          .then(() => {
            this.fetchTeams();
            this.newMemberId[teamId] = '';
          })
          .catch(error => {
            console.error('Error adding user to team:', error.response ? error.response.data : error);
          });
      },
      deleteTeam(teamId) {
        this.setAuthHeader();
        axios.delete(`http://localhost:4000/api/teams/${teamId}`)
          .then(() => {
            this.fetchTeams();
          })
          .catch(error => {
            console.error('Error deleting team:', error.response ? error.response.data : error);
          });
      },
       // Supprimer un membre d'une équipe
  removeMemberFromTeam(teamId, userId) {
    this.setAuthHeader(); // Ajouter le token JWT à chaque requête
    axios.delete(`http://localhost:4000/api/teams/${teamId}/members/${userId}`)
      .then(() => {
        this.fetchTeams(); // Recharger la liste des équipes après suppression du membre
      })
      .catch(error => {
        console.error('Error removing member from team:', error.response ? error.response.data : error);
      });
  },
    }
  };
  </script>
  