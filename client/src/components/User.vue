<template>
  <div class="bg-bat-gray rounded-lg shadow-bat p-6">
    <h2 class="text-2xl font-bold mb-6 text-bat-yellow">
      Base de Données des Citoyens de Gotham
    </h2>

    <!-- Champs de saisie -->
    <div class="space-y-4 mb-6">
      <div>
        <label for="userName" class="block text-sm font-medium text-bat-silver mb-1">Alias :</label>
        <input
          type="text"
          v-model="userName"
          id="userName"
          placeholder="Entrez l'alias du citoyen"
          class="w-full px-3 py-2 bg-bat-black border border-bat-silver rounded-md text-bat-silver focus:outline-none focus:border-bat-yellow"
        />
      </div>

      <div>
        <label for="userEmail" class="block text-sm font-medium text-bat-silver mb-1">Canal de Communication :</label>
        <input
          type="email"
          v-model="userEmail"
          id="userEmail"
          placeholder="Entrez l'email sécurisé"
          class="w-full px-3 py-2 bg-bat-black border border-bat-silver rounded-md text-bat-silver focus:outline-none focus:border-bat-yellow"
        />
      </div>

      <div>
        <label for="userId" class="block text-sm font-medium text-bat-silver mb-1">Code d'Identification :</label>
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
      <button @click="createUser" class="bat-button bat-button-blue">
        Enregistrer le Citoyen
      </button>
      <button @click="updateUser" class="bat-button bat-button-blue">
        Mettre à Jour le Citoyen
      </button>
      <button @click="getUser" class="bat-button bat-button-gray">
        Localiser le Citoyen
      </button>
      <button @click="getAllUsers" class="bat-button bat-button-yellow">
        Voir Tous les Citoyens
      </button>
      <button @click="deleteUser" class="bat-button bat-button-red col-span-2">
        Effacer les Dossiers
      </button>
    </div>

    <!-- Affichage des informations de l'utilisateur -->
    <div v-if="userData" class="mt-6 p-4 bg-bat-black rounded-lg border border-bat-yellow">
      <h3 class="text-lg font-semibold mb-2 text-bat-yellow">Profil du Citoyen</h3>
      <p class="text-bat-silver">
        <strong class="text-bat-blue">ID :</strong> {{ userData.data.id }}
      </p>
      <p class="text-bat-silver">
        <strong class="text-bat-blue">Alias :</strong> {{ userData.data.username }}
      </p>
      <p class="text-bat-silver">
        <strong class="text-bat-blue">Canal :</strong> {{ userData.data.email }}
      </p>
    </div>

    <!-- Affichage de tous les utilisateurs -->
    <div v-if="users.data && users.data.length" class="mt-6">
      <h3 class="text-lg font-semibold mb-2 text-bat-yellow">Registre des Citoyens de Gotham</h3>
      <ul class="bg-bat-black rounded-lg divide-y divide-bat-gray">
        <li v-for="user in users.data" :key="user.id" class="px-4 py-3 text-bat-silver">
          <div class="flex items-center justify-between bg-bat-black text-bat-silver py-2 px-4 rounded-md">
            <div class="flex-grow">
              {{ user.id }} - {{ user.username }} - {{ user.email }}
            </div>
            <div class="flex-shrink-0 flex items-center">
              <button @click="selectUserForUpdate(user)">
                <img src="@/assets/icons/edit-icon.png" alt="Edit" class="w-4 h-4 ml-4 mr-2" />
              </button>
              <button @click="deleteUserById(user.id)">
                <img src="@/assets/icons/delete-icon.png" alt="Delete" class="w-4 h-4 ml-2" />
              </button>
            </div>
          </div>
        </li>
      </ul>
    </div>

    <!-- Error Display -->
    <div v-if="error" class="mt-4 p-4 bg-red-100 border border-red-400 text-red-700 rounded-lg">
      {{ error }}
    </div>
  </div>
</template>

<script>
import api from '@/services/api_token';

export default {
  name: 'User',
  data() {
    return {
      userName: "",
      userEmail: "",
      userId: "",
      userData: null,
      users: [],
      error: null
    };
  },

  created() {
    // Check if user is authenticated and has proper role
    const token = localStorage.getItem('token');
    const role = localStorage.getItem('role');
    
    if (!token) {
      this.$router.push('/login');
      return;
    }

    // if (role !== 'general_manager') {
    //   this.error = "Accès non autorisé. Seuls les general managers peuvent accéder à cette page.";
    //   setTimeout(() => {
    //     this.$router.push('/login');
    //   }, 2000);
    //   return;
    // }

    // If there's an ID in the URL, load that user
    const userIdFromUrl = this.$route.query.id;
    if (userIdFromUrl) {
      this.userId = userIdFromUrl;
      this.getUser();
    }
  },

  methods: {
    async createUser() {
      try {
        this.error = null;
        this.users = [];
        
        const response = await api.post('/users', {
          user: {
            username: this.userName,
            email: this.userEmail,
          },
        });

        this.userData = response.data;
        alert("Citoyen enregistré avec succès");
        this.clearForm();
      } catch (error) {
        this.handleError(error, "l'enregistrement du citoyen");
      }
    },

    async getUser() {
      try {
        this.error = null;
        this.users = [];

        let response;
        if (this.userName && this.userEmail) {
          response = await api.get('/users/lookup', {
            params: {
              username: this.userName,
              email: this.userEmail,
            },
          });
        } else if (this.userId) {
          response = await api.get(`/users/${this.userId}`);
        } else {
          throw new Error("Veuillez fournir soit un nom d'utilisateur et un email, soit un ID.");
        }

        this.userData = response.data;
        this.updateUrlWithUserId(this.userData.data.id);
      } catch (error) {
        this.handleError(error, "la recherche du citoyen");
      }
    },

    async getAllUsers() {
      try {
        this.error = null;
        this.userData = null;
        
        const response = await api.get('/users');
        this.users = response.data;
        this.resetUrl();
      } catch (error) {
        this.handleError(error, "la récupération de tous les citoyens");
      }
    },

    async updateUser() {
      try {
        this.error = null;
        if (!this.userId) {
          throw new Error("ID du citoyen requis pour la mise à jour");
        }

        const response = await api.put(`/users/${this.userId}`, {
          user: {
            username: this.userName,
            email: this.userEmail,
          },
        });

        this.userData = response.data;
        alert("Informations du citoyen mises à jour avec succès");
        this.users = [];
      } catch (error) {
        this.handleError(error, "la mise à jour du citoyen");
      }
    },

    async deleteUser() {
      try {
        this.error = null;
        if (!this.userId) {
          throw new Error("ID du citoyen requis pour la suppression");
        }

        await api.delete(`/users/${this.userId}`);
        this.userData = null;
        alert("Dossier du citoyen supprimé avec succès");
        this.clearForm();
        this.resetUrl();
      } catch (error) {
        this.handleError(error, "la suppression du citoyen");
      }
    },

    async deleteUserById(id) {
      try {
        this.error = null;
        await api.delete(`/users/${id}`);
        await this.getAllUsers();
        alert("Dossier du citoyen supprimé avec succès");
      } catch (error) {
        this.handleError(error, "la suppression du citoyen");
      }
    },

    selectUserForUpdate(user) {
      this.userId = user.id;
      this.userName = user.username;
      this.userEmail = user.email;
      this.updateUrlWithUserId(user.id);
    },

    clearForm() {
      this.userName = "";
      this.userEmail = "";
      this.userId = "";
    },

    updateUrlWithUserId(id) {
      this.$router.push({
        path: this.$route.path,
        query: { id: id },
      });
    },

    resetUrl() {
      this.$router.replace({
        path: this.$route.path,
        query: {},
      });
    },

    handleError(error, action) {
      if (error.response) {
        const status = error.response.status;
        if (status === 401) {
          this.error = "Session expirée. Veuillez vous reconnecter.";
          setTimeout(() => {
            this.$router.push('/login');
          }, 2000);
        } else if (status === 403) {
          this.error = "Accès non autorisé. Droits insuffisants.";
        } else {
          const message = error.response.data.errors?.detail || 
                         error.response.data.message || 
                         error.response.statusText;
          this.error = `Erreur lors de ${action}: ${message}`;
        }
      } else if (error.request) {
        this.error = `Pas de réponse du serveur lors de ${action}. Veuillez vérifier votre connexion.`;
      } else {
        this.error = `Erreur lors de ${action}: ${error.message}`;
      }

      // Clear error after 5 seconds
      setTimeout(() => {
        this.error = null;
      }, 5000);
    }
  },

  beforeRouteUpdate(to, from, next) {
    if (to.query.id !== from.query.id) {
      this.userId = to.query.id;
      if (this.userId) {
        this.getUser();
      }
    }
    next();
  }
};
</script>

<style scoped>
.bat-button {
  @apply py-2 px-4 rounded-md text-sm font-medium transition duration-150 ease-in-out;
}

.bat-button-blue {
  @apply bg-blue-600 text-white hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2;
}

.bat-button-gray {
  @apply bg-gray-600 text-white hover:bg-gray-700 focus:outline-none focus:ring-2 focus:ring-gray-500 focus:ring-offset-2;
}

.bat-button-yellow {
  @apply bg-yellow-500 text-black hover:bg-yellow-600 focus:outline-none focus:ring-2 focus:ring-yellow-400 focus:ring-offset-2;
}

.bat-button-red {
  @apply bg-red-600 text-white hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-red-500 focus:ring-offset-2;
}
</style>