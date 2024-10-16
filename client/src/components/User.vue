<!-- eslint-disable vue/multi-word-component-names -->
<template>
  <div class="bg-bat-gray rounded-lg shadow-bat p-6">
    <h2 class="text-2xl font-bold mb-6 text-bat-yellow">
      Base de Données des Citoyens de Gotham
    </h2>

    <!-- Champs de saisie -->
    <div class="space-y-4 mb-6">
      <div>
        <label
          for="userName"
          class="block text-sm font-medium text-bat-silver mb-1"
          >Alias :</label
        >
        <input
          type="text"
          v-model="userName"
          id="userName"
          placeholder="Entrez l'alias du citoyen"
          class="w-full px-3 py-2 bg-bat-black border border-bat-silver rounded-md text-bat-silver focus:outline-none focus:border-bat-yellow"
        />
      </div>

      <div>
        <label
          for="userEmail"
          class="block text-sm font-medium text-bat-silver mb-1"
          >Canal de Communication :</label
        >
        <input
          type="email"
          v-model="userEmail"
          id="userEmail"
          placeholder="Entrez l'email sécurisé"
          class="w-full px-3 py-2 bg-bat-black border border-bat-silver rounded-md text-bat-silver focus:outline-none focus:border-bat-yellow"
        />
      </div>

      <div>
        <label
          for="userId"
          class="block text-sm font-medium text-bat-silver mb-1"
          >Code d'Identification :</label
        >
        <input
          type="text"
          v-model="userId"
          id="userId"
          placeholder="Entrez l'ID unique"
          class="w-full px-3 py-2 bg-bat-black border border-bat-silver rounded-md text-bat-silver focus:outline-none focus:border-bat-yellow"
        />
      </div>
    </div>

    <!-- Boutons d'action -->
    <div class="grid grid-cols-2 gap-4 mb-6">
      <button @click="createUser" class="bat-button bg-bat-blue">
        Enregistrer le Citoyen
      </button>
      <button @click="updateUser" class="bat-button bg-bat-blue">
        Mettre à Jour le Citoyen
      </button>
      <button @click="getUser" class="bat-button bg-bat-silver text-bat-black">
        Localiser le Citoyen
      </button>
      <button
        @click="getAllUsers"
        class="bat-button bg-bat-yellow text-bat-black"
      >
        Voir Tous les Citoyens
      </button>
      <button @click="deleteUser" class="bat-button bg-red-600 col-span-2">
        Effacer les Dossiers
      </button>
    </div>

    <!-- Affichage des informations de l'utilisateur -->
    <div
      v-if="userData"
      class="mt-6 p-4 bg-bat-black rounded-lg border border-bat-yellow"
    >
      <h3 class="text-lg font-semibold mb-2 text-bat-yellow">
        Profil du Citoyen
      </h3>
      <p class="text-bat-silver">
        <strong class="text-bat-blue">ID :</strong> {{ userData.data.id }}
      </p>
      <p class="text-bat-silver">
        <strong class="text-bat-blue">Alias :</strong>
        {{ userData.data.username }}
      </p>
      <p class="text-bat-silver">
        <strong class="text-bat-blue">Canal :</strong>
        {{ userData.data.email }}
      </p>
    </div>

    <!-- Affichage de tous les utilisateurs -->
    <div v-if="users.data && users.data.length" class="mt-6">
      <h3 class="text-lg font-semibold mb-2 text-bat-yellow">
        Registre des Citoyens de Gotham
      </h3>
      <ul class="bg-bat-black rounded-lg divide-y divide-bat-gray">
        <li
          v-for="user in users.data"
          :key="user.id"
          class="px-4 py-3 text-bat-silver"
        >
          <!-- User List Item -->
          <div
            class="flex items-center justify-between bg-bat-black text-bat-silver py-2 px-4 rounded-md"
          >
            <!-- User Information (ensure this doesn't expand) -->
            <div class="flex-grow">
              {{ user.id }} - {{ user.username }} - {{ user.email }}
            </div>

            <!-- Buttons Container (fixed width) -->
            <div class="flex-shrink-0 flex items-center">
              <!-- Update Button -->
              <button @click="selectUserForUpdate(user)">
                <img
                  src="@/assets/icons/edit-icon.png"
                  alt="Edit"
                  class="w-4 h-4 ml-4 mr-2"
                />
              </button>

              <!-- Delete Button -->
              <button @click="deleteUserById(user.id)">
                <img
                  src="@/assets/icons/delete-icon.png"
                  alt="Delete"
                  class="w-4 h-4 ml-2"
                />
              </button>
            </div>
          </div>
        </li>
      </ul>
    </div>
  </div>
</template>

<script>
// import apiClient from '@/services/api';

  import axios from 'axios';

  console.log('VUE_APP_API_URL:', process.env.VUE_APP_API_URL);

  const apiClient = axios.create({
    baseURL: process.env.VUE_APP_API_URL || "/api",
    headers: {
      'Content-Type': 'application/json'
    }
  });

export default {
  data() {
    return {
      userName: "",
      userEmail: "",
      userId: "", // This will be used to get or delete a specific user
      userData: null, // To store a single user's data
      users: [], // To store all users when calling getAllUsers
    };
  },
  //   mounted() {
  //     // Automatically fetch all users when the component is mounted
  //     this.getAllUsers();
  //   },
  methods: {
    async createUser() {
      try {
        // Clear the list of users
        this.users = [];

        const response = await axios.post(`/api/users`, {
          user: {
            username: this.userName,
            email: this.userEmail,
          },
        });

        this.userData = response.data;
        alert("User created successfully");
      } catch (error) {
        if (error.response && error.response.status === 500) {
          // Handle conflict error (user already exists)
          alert("User already exists in the database.");
        } else {
          this.handleError(error, "creating user");
        }
      }
    },
    async getUser() {
      try {
        // Clear the list of users
        this.users = [];

        if (this.userName && this.userEmail) {
          // Fetch user data by username and email
          const response = await apiClient.get(
            `/api/users/user`,
            {
              params: {
                username: this.userName,
                email: this.userEmail,
              },
            }
          );
          this.userData = response.data;

          // Add query params to the URL for userId
          this.$router.push({
            path: "/",
            query: {
              id: this.userData.data.id,
            },
          });
        } else if (this.userId) {
          // Add query params to the URL for userId
          this.$router.push({
            path: "/",
            query: {
              id: this.userId,
            },
          });

          // Fetch user data by userId
          const response = await apiClient.get(
            `/api/users/${this.userId}`
          );
          this.userData = response.data;
        } else {
          // Handle missing input
          alert("Please provide either username & email or user ID.");
        }
      } catch (error) {
        this.handleError(error, "getting user");
      }
    },
    async getAllUsers() {
      try {
        // Clear the individual user
        this.userData = null;

        const response = await axios.get(`http://elixir-backend:4000/api/users`);
        this.users = response.data;
        console.log(this.users);
        alert("Get all users successful");
        this.resetUrl();
      } catch (error) {
        this.handleError(error, "getting all users");
      }
    },
    async updateUser() {
      try {
        const response = await apiClient.put(
          `/api/users/${this.userId}`,
          {
            user: {
              username: this.userName,
              email: this.userEmail,
            },
          }
        );
        this.userData = response.data;
        alert("User updated successfully");

        // Clear the list of users
        this.users = [];
      } catch (error) {
        this.handleError(error, "updating user");
      }
    },
    async deleteUser() {
      try {
        await apiClient.delete(`/api/users/${this.userId}`);
        this.userData = null; // Clear the data after deletion
        alert("User deleted successfully");
        this.resetUrl();
      } catch (error) {
        this.handleError(error, "deleting user");
      }
    },
    async deleteUserById(id) {
      try {
        await apiClient.delete(`/api/users/${id}`);
        this.getAllUsers(); // Refresh the user list after deletion
        alert("User deleted successfully");
      } catch (error) {
        this.handleError(error, "deleting user");
      }
    },
    resetUrl() {
      // Create a new route object, excluding the 'id' query parameter
      this.$router.replace({
        path: this.$route.path, // Keep the current path
        query: {}, // Set the query object to an empty object to remove all query parameters
      });
    },
    selectUserForUpdate(user) {
      // Prefill the form with selected user's data for update
      this.userId = user.id;
      this.userName = user.username;
      this.userEmail = user.email;
      // Add query params to the URL for userId
      this.$router.push({
        path: "/",
        query: {
          id: this.userId,
        },
      });
    },
    handleError(error, action) {
      if (error.response) {
        const status = error.response.status;
        const message =
          error.response.data.message || error.response.statusText;
        alert(`Error ${status}: ${message} while ${action}`);
      } else if (error.request) {
        alert(
          `No response received from server while ${action}. Please check your network or try again later.`
        );
      } else {
        alert(`Error while ${action}: ${error.message}`);
      }
    },
  },

  //   mounted() {
  //   const userIdFromUrl = this.$route.query.id;
  //   console.log('userIdFromUrl',userIdFromUrl)
  // },
  created() {
    console.log('API URL from env:', process.env.VUE_APP_API_URL);
    console.log('apiClient baseURL:', apiClient.defaults.baseURL);
    console.log('Full apiClient config:', apiClient.defaults);
  }
};
</script>
