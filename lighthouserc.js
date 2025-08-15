// Lighthouse CI Configuration
// This file configures Lighthouse CI for performance monitoring

module.exports = {
  ci: {
    collect: {
      url: ['https://harrylclc.github.io/'],
      startServerCommand: 'bundle exec jekyll serve',
      startServerReadyPattern: 'Server running',
      numberOfRuns: 3,
    },
    assert: {
      assertions: {
        'categories:performance': ['warn', { minScore: 0.9 }],
        'categories:accessibility': ['error', { minScore: 0.95 }],
        'categories:best-practices': ['warn', { minScore: 0.9 }],
        'categories:seo': ['error', { minScore: 0.95 }],
        'categories:pwa': 'off',
      },
    },
    upload: {
      target: 'temporary-public-storage',
    },
  },
};
