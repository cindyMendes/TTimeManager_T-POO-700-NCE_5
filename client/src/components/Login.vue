<template>
  <div class="min-h-screen flex items-center justify-center bg-bat-black py-12 px-4 sm:px-6 lg:px-8">
    <div class="bg-bat-gray rounded-lg shadow-bat p-6 max-w-md w-full space-y-8">
      <div>
        <img class="mx-auto h-20 w-auto" src="@/assets/pngegg.png" alt="Logo Batman">
        <h2 id="login-title" class="mt-6 text-center text-3xl font-bold text-bat-yellow">Accès au Bat-Ordinateur</h2>
      </div>
      
      <form @submit.prevent="handleLogin" aria-labelledby="login-title" class="mt-8 space-y-6">
        <div class="rounded-md shadow-sm -space-y-px">
          <div>
            <label for="email" class="block text-bat-silver mb-2">Identifiant</label>
            <input
              type="email"
              id="email"
              v-model="email"
              required
              class="appearance-none rounded-t-md relative block w-full px-3 py-2 border border-bat-silver bg-bat-black text-bat-silver placeholder-bat-silver focus:outline-none focus:ring-bat-yellow focus:border-bat-yellow focus:z-10 sm:text-sm"
              placeholder="Entrez votre email"
              aria-describedby="email-error"
            >
          </div>
          <div>
            <label for="password" class="block text-bat-silver mb-2 mt-4">Code d'accès</label>
            <input
              type="password"
              id="password"
              v-model="password"
              required
              class="appearance-none rounded-b-md relative block w-full px-3 py-2 border border-bat-silver bg-bat-black text-bat-silver placeholder-bat-silver focus:outline-none focus:ring-bat-yellow focus:border-bat-yellow focus:z-10 sm:text-sm"
              placeholder="Entrez votre mot de passe"
              aria-describedby="password-error"
            >
          </div>
        </div>

        <div>
          <button
            type="submit"
            class="group relative w-full flex justify-center py-2 px-4 border border-transparent text-sm font-medium rounded-md text-bat-black bg-bat-yellow hover:bg-bat-yellow-light focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-bat-yellow transition duration-150 ease-in-out"
            :disabled="isLoading"
            aria-busy="isLoading"
          >
            <span class="absolute left-0 inset-y-0 flex items-center pl-3">
              <svg class="h-5 w-5 text-bat-yellow-dark group-hover:text-bat-yellow-light transition ease-in-out duration-150" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M5 9V7a5 5 0 0110 0v2a2 2 0 012 2v5a2 2 0 01-2 2H5a2 2 0 01-2-2v-5a2 2 0 012-2zm8-2v2H7V7a3 3 0 016 0z" clip-rule="evenodd" />
              </svg>
            </span>
            {{ isLoading ? 'Connexion en cours...' : 'Se connecter' }}
          </button>
        </div>
      </form>
      
      <div class="text-center">
        <p class="mt-2 text-sm text-bat-silver">
          Pas encore de compte ?
          <router-link to="/signup" class="font-medium text-bat-yellow hover:text-bat-yellow-light">
            S'inscrire
          </router-link>
        </p>
      </div>

      <div v-if="Object.keys(errors).length > 0" class="mt-4 bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded relative" role="alert">
        <strong class="font-bold">Erreur ! </strong>
        <span class="block sm:inline">{{ errors.general || "Une erreur s'est produite. Veuillez réessayer." }}</span>
      </div>
    </div>
  </div>
</template>

<script>
import api from '@/services/api_token';

export default {
  name: 'Log-in',
  data() {
    return {
      email: '',
      password: '',
      errors: {},
      isLoading: false
    }
  },
  methods: {
    async handleLogin() {
      this.errors = {};
      this.isLoading = true;

      try {
        const response = await api.post('/auth/login', {
          email: this.email,
          password: this.password
        });

        console.log('RESPONSE', response);
        const { token, user } = response.data;

        // Store authentication data
        localStorage.setItem('token', token);
        localStorage.setItem('role', user.role);
        localStorage.setItem('userId', user.id);
        
        // Fetch complete user info
        const userDetails = await this.getUserDetails(user.id);
        if (userDetails) {
          // Store complete user info
          localStorage.setItem('userEmail', userDetails.email);
          localStorage.setItem('userName', userDetails.username || '');
          localStorage.setItem('userDetails', JSON.stringify(userDetails));
        }
        
        console.log(`Utilisateur connecté avec le rôle : ${user.role}`);

        // Redirect based on role with user info
        this.redirectBasedOnRole(user.role);
      } catch (error) {
        console.error('Erreur de connexion:', error);
        this.handleLoginError(error);
      } finally {
        this.isLoading = false;
      }
    },

    async getUserDetails(userId) {
      try {
        const response = await api.get(`/users/${userId}`);
        console.log('User Details:', response.data);
        return response.data.data;
      } catch (error) {
        console.error('Erreur lors de la récupération des détails utilisateur:', error);
        this.handleError(error, "la récupération des détails utilisateur");
        return null;
      }
    },

    redirectBasedOnRole(role) {
      const roleRoutes = {
        'employee': '/employee-dashboard',
        'manager': '/manager-dashboard',
        'general_manager': '/general-manager-dashboard',
        'admin': '/admin-dashboard'
      };

      const route = roleRoutes[role] || '/';
      this.$router.push({
        path: route,
        query: { 
          fromLogin: 'true'
        }
      });
    },

    handleLoginError(error) {
      if (error.response) {
        const status = error.response.status;
        switch (status) {
          case 401:
            this.errors = { 
              general: "Identifiants incorrects. Veuillez vérifier votre email et mot de passe." 
            };
            break;
          case 403:
            this.errors = { 
              general: "Accès non autorisé." 
            };
            break;
          case 404:
            this.errors = { 
              general: "Service d'authentification non disponible." 
            };
            break;
          case 422:
            this.errors = { 
              general: "Données invalides. Veuillez vérifier vos informations." 
            };
            break;
          default:
            this.errors = { 
              general: "Une erreur s'est produite lors de la connexion. Veuillez réessayer." 
            };
        }
        console.log('Détails de l\'erreur:', error.response.data);
      } else if (error.request) {
        this.errors = { 
          general: "Impossible de contacter le serveur. Veuillez vérifier votre connexion."
        };
      } else {
        this.errors = { 
          general: "Une erreur inattendue s'est produite. Veuillez réessayer."
        };
      }
    }
  },

  // Clear any stored auth data when component is mounted
  mounted() {
    localStorage.removeItem('token');
    localStorage.removeItem('role');
    localStorage.removeItem('userId');
    localStorage.removeItem('userEmail');
    localStorage.removeItem('userName');
    localStorage.removeItem('userDetails');
  }
}
</script>