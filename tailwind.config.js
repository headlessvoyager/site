/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./templates/**/*.html",
    "./content/**/*.md",
    "./themes/apollo/templates/**/*.html",
  ],
  theme: {
    extend: {
      colors: {
        // Background colors
        "bg-0": "var(--bg-0)",
        "bg-1": "var(--bg-1)",
        "bg-2": "var(--bg-2)",
        // Text colors
        "text-0": "var(--text-0)",
        "text-1": "var(--text-1)",
        // Theme colors
        primary: "var(--primary-color)",
        hover: "var(--hover-color)",
        // Border color
        border: "var(--border-color)",
      },
      fontFamily: {
        // Use theme font variables
        sans: ["var(--text-font)", "sans-serif"],
        text: ["var(--text-font)", "sans-serif"],
        header: ["var(--header-font)"],
        code: ["var(--code-font)", "monospace"],
      },
    },
  },
  plugins: [],
};
