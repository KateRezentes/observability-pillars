// JavaScript hooks for LiveView
const Hooks = {
  Sidebar: {
    mounted() {
      const sidebarToggle = document.getElementById('sidebar-toggle');
      const sidebarClose = document.getElementById('sidebar-close');
      const sidebar = document.getElementById('sidebar');
      
      sidebarToggle.addEventListener('click', () => {
        sidebar.classList.toggle('translate-x-full');
      });
      
      sidebarClose.addEventListener('click', () => {
        sidebar.classList.add('translate-x-full');
      });
      
      // Close sidebar when clicking outside
      document.addEventListener('click', (e) => {
        if (!sidebar.contains(e.target) && e.target !== sidebarToggle) {
          sidebar.classList.add('translate-x-full');
        }
      });
    }
  }
};

export default Hooks;
