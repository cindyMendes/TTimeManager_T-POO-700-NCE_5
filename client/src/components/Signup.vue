<template>
  <div class="min-h-screen flex items-center justify-center bg-image">
    <!-- Lightning Effects -->
    <div class="lightning-container">
      <div class="lightning-1"></div>
      <div class="lightning-2"></div>
      <div class="lightning-3"></div>
    </div>

    <!-- Main Content -->
    <div class="max-w-md w-full mx-4 space-y-8 bg-zinc-800/90 backdrop-blur-sm rounded-lg p-8 shadow-2xl relative">
      <div>
        <img class="mx-auto h-24 w-auto" src="../assets/pngegg.png" alt="Logo Batman">
        <h2 class="mt-6 text-center text-3xl font-bold text-bat-yellow glow-text">Rejoindre la Bat-Famille</h2>
      </div>
      
      <form @submit.prevent="handleSignup" class="mt-8 space-y-6">
        <div class="rounded-md -space-y-px">
          <div>
            <label for="username" class="block text-bat-silver mb-2">Nom de code</label>
            <input
              type="text"
              id="username"
              v-model="username"
              required
              class="appearance-none rounded-md relative block w-full px-3 py-2 border border-bat-silver bg-black/50 text-bat-silver placeholder-bat-silver/70 focus:outline-none focus:ring-bat-yellow focus:border-bat-yellow transition-all duration-200"
              placeholder="Entrez votre nom de code"
            >
          </div>
          <div class="mt-4">
            <label for="email" class="block text-bat-silver mb-2">Adresse de communication</label>
            <input
              type="email"
              id="email"
              v-model="email"
              required
              class="appearance-none rounded-md relative block w-full px-3 py-2 border border-bat-silver bg-black/50 text-bat-silver placeholder-bat-silver/70 focus:outline-none focus:ring-bat-yellow focus:border-bat-yellow transition-all duration-200"
              placeholder="Entrez votre email"
            >
          </div>
          <div class="mt-4">
            <label for="password" class="block text-bat-silver mb-2">Code d'accès secret</label>
            <input
              type="password"
              id="password"
              v-model="password"
              required
              minlength="6"
              class="appearance-none rounded-md relative block w-full px-3 py-2 border border-bat-silver bg-black/50 text-bat-silver placeholder-bat-silver/70 focus:outline-none focus:ring-bat-yellow focus:border-bat-yellow transition-all duration-200"
              placeholder="Entrez votre mot de passe"
            >
          </div>
          <div class="mt-4">
            <label for="confirmPassword" class="block text-bat-silver mb-2">Confirmer le code d'accès</label>
            <input
              type="password"
              id="confirmPassword"
              v-model="confirmPassword"
              required
              class="appearance-none rounded-md relative block w-full px-3 py-2 border border-bat-silver bg-black/50 text-bat-silver placeholder-bat-silver/70 focus:outline-none focus:ring-bat-yellow focus:border-bat-yellow transition-all duration-200"
              placeholder="Confirmez votre mot de passe"
            >
          </div>
        </div>

        <div>
          <button
            type="submit"
            class="group relative w-full flex justify-center py-3 px-4 border border-transparent text-sm font-medium rounded-md text-bat-black bg-bat-yellow hover:bg-bat-yellow-light focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-bat-yellow transition-all duration-300 transform hover:scale-105"
            :disabled="isLoading"
          >
            <span class="absolute left-0 inset-y-0 flex items-center pl-3">
              <svg class="h-5 w-5 text-bat-yellow-dark group-hover:text-bat-yellow-light transition ease-in-out duration-150" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
                <path fill-rule="evenodd" d="M5 9V7a5 5 0 0110 0v2a2 2 0 012 2v5a2 2 0 01-2 2H5a2 2 0 01-2-2v-5a2 2 0 012-2zm8-2v2H7V7a3 3 0 016 0z" clip-rule="evenodd" />
              </svg>
            </span>
            {{ isLoading ? 'Inscription en cours...' : 'Rejoindre' }}
          </button>
        </div>

        <!-- Error display -->
        <div v-if="Object.keys(errors).length > 0" 
             class="bg-red-900/50 text-red-200 p-4 rounded-md backdrop-blur-sm border border-red-800">
          <p v-for="(error, key) in errors" :key="key" class="text-sm">
            {{ error }}
          </p>
        </div>
      </form>
      
      <p class="mt-2 text-center text-sm text-bat-silver">
        Déjà membre ?
        <router-link to="/login" class="font-medium text-bat-yellow hover:text-bat-yellow-light transition-colors duration-200">
          Se connecter
        </router-link>
      </p>
    </div>
  </div>
</template>

<style scoped>
.bg-image {
  background-image: url('@/assets/gotham.png');
  background-size: cover;
  background-position: center;
  background-repeat: no-repeat;
  position: relative;
  overflow: hidden;
}

/* Lightning Container and Effects */
.lightning-container {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  pointer-events: none;
}

.lightning-1, .lightning-2, .lightning-3 {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: transparent;
}

.lightning-1 {
  animation: lightning1 12s infinite;
}

.lightning-2 {
  animation: lightning2 15s infinite 1s;
}

.lightning-3 {
  animation: lightning3 18s infinite 2s;
}

@keyframes lightning1 {
  0% { background: transparent; }
  2% { background: rgba(255, 255, 255, 0.2); }
  3% { background: transparent; }
  6% { background: transparent; }
  8% { background: rgba(255, 255, 255, 0.2); }
  9% { background: transparent; }
  100% { background: transparent; }
}

@keyframes lightning2 {
  0% { background: transparent; }
  1% { background: rgba(255, 255, 255, 0.2); }
  2% { background: transparent; }
  4% { background: transparent; }
  6% { background: rgba(255, 255, 255, 0.2); }
  7% { background: transparent; }
  100% { background: transparent; }
}

@keyframes lightning3 {
  0% { background: transparent; }
  3% { background: rgba(255, 255, 255, 0.2); }
  4% { background: transparent; }
  7% { background: transparent; }
  9% { background: rgba(255, 255, 255, 0.2); }
  10% { background: transparent; }
  100% { background: transparent; }
}

.glow-text {
  text-shadow: 
    0 0 10px rgba(255, 238, 31, 0.7),
    0 0 20px rgba(255, 238, 31, 0.5),
    0 0 30px rgba(255, 238, 31, 0.3);
}

/* Input focus effects */
input:focus {
  box-shadow: 0 0 10px rgba(255, 238, 31, 0.3);
}

/* Button hover effect */
button:hover {
  box-shadow: 0 0 15px rgba(255, 238, 31, 0.4);
}

/* Card shadow effect synced with lightning */
@keyframes cardGlow {
  0% { box-shadow: 0 8px 32px rgba(0, 0, 0, 0.2); }
  2% { box-shadow: 0 8px 32px rgba(255, 255, 255, 0.3); }
  3% { box-shadow: 0 8px 32px rgba(0, 0, 0, 0.2); }
  100% { box-shadow: 0 8px 32px rgba(0, 0, 0, 0.2); }
}

/* Responsive adjustments */
@media (max-width: 640px) {
  .bg-image {
    background-position: center;
  }
}
</style>
  
<script>
import api from '@/services/api_token';

export default {
  name: 'Sign-up',
  data() {
    return {
      username: '',
      email: '',
      password: '',
      confirmPassword: '',
      errors: {},
      isLoading: false
    }
  },
  methods: {
    validateForm() {
      const errors = {};
      
      if (this.password.length < 6) {
        errors.password = "Le code d'accès doit contenir au moins 6 caractères.";
      }
      
      if (this.password !== this.confirmPassword) {
        errors.confirmPassword = "Les codes d'accès ne correspondent pas.";
      }
      
      if (!this.email.includes('@')) {
        errors.email = "Veuillez entrer une adresse email valide.";
      }
      
      if (this.username.length < 3) {
        errors.username = "Le nom de code doit contenir au moins 3 caractères.";
      }
      
      return errors;
    },

    async handleSignup() {
      this.errors = {};
      this.isLoading = true;

      // Form validation
      const validationErrors = this.validateForm();
      if (Object.keys(validationErrors).length > 0) {
        this.errors = validationErrors;
        this.isLoading = false;
        return;
      }
      
      try {
        const response = await api.post('/auth/signup', {
          user: {
            username: this.username,
            email: this.email,
            password: this.password,
            role: 'employee' // Default role for new users
          }
        });

        console.log('Inscription réussie:', response.data);
        
        // Show success message
        this.$router.push({
          path: '/login',
          query: { 
            message: 'Inscription réussie! Vous pouvez maintenant vous connecter.' 
          }
        });
      } catch (error) {
        this.handleSignupError(error);
      } finally {
        this.isLoading = false;
      }
    },

    handleSignupError(error) {
      if (error.response) {
        const status = error.response.status;
        const data = error.response.data;

        switch (status) {
          case 422:
            if (data.errors) {
              this.errors = {
                email: data.errors.email?.join(', '),
                username: data.errors.username?.join(', '),
                password: data.errors.password?.join(', ')
              };
            } else {
              this.errors.general = "Données invalides. Veuillez vérifier vos informations.";
            }
            break;
          case 409:
            this.errors.email = "Cette adresse email est déjà utilisée.";
            break;
          case 500:
            this.errors.general = "Une erreur serveur s'est produite. Veuillez réessayer plus tard.";
            break;
          default:
            this.errors.general = "Une erreur s'est produite lors de l'inscription. Veuillez réessayer.";
        }
        
        console.error('Erreur d\'inscription:', error.response.data);
      } else if (error.request) {
        this.errors.general = "Impossible de contacter le serveur. Veuillez vérifier votre connexion.";
      } else {
        this.errors.general = "Une erreur inattendue s'est produite. Veuillez réessayer.";
      }
    }
  }
}
</script>