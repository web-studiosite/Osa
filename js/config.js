// ============================================================================
// CONFIGURAÇÃO DO BANCO DE DADOS SUPABASE (URL E CHAVE ANON)
// ============================================================================
// Cole aqui as credenciais do seu projeto Supabase se desejar que a aplicação
// conecte automaticamente ao carregar:

window.SUPABASE_CONFIG = {
  // Cole a URL do seu projeto Supabase aqui:
  url: "https://shxcvouxknsdazybwfrr.supabase.co", // Exemplo: "https://abcdefghijklm.supabase.co"

  // Cole a chave pública (anon key) do seu Supabase aqui:
  anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNoeGN2b3V4a25zZGF6eWJ3ZnJyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODc1MTg4MzksImV4cCI6MjEwMzA5NDgzOX0.1qsbyCNVOYGBYjX_mpGWBd9B7Vk8WgUWhAy5UcinaX8", // Exemplo: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."

  // Deixe como true para conectar à nuvem do Supabase:
  useLiveSupabase: true
};
