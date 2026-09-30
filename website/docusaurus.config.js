// @ts-check
import {themes as prismThemes} from 'prism-react-renderer';

/** @type {import('@docusaurus/types').Config} */
const config = {
  title: 'Kong AI Gateway Workshop',
  tagline: 'Konnect Serverless + Workshop LLM Hub',
  favicon: 'img/favicon.ico',

  url: 'https://great-stone-kong.github.io',
  baseUrl: '/kong-ai-gateway-workshop/',

  organizationName: 'Great-Stone-Kong',
  projectName: 'kong-ai-gateway-workshop',
  deploymentBranch: 'gh-pages',
  trailingSlash: false,

  onBrokenLinks: 'warn',
  onBrokenMarkdownLinks: 'warn',

  markdown: {
    format: 'md',
  },

  i18n: {
    defaultLocale: 'ko',
    locales: ['ko', 'en'],
    localeConfigs: {
      ko: {label: '한국어', direction: 'ltr', htmlLang: 'ko'},
      en: {label: 'English', direction: 'ltr', htmlLang: 'en'},
    },
  },

  presets: [
    [
      'classic',
      /** @type {import('@docusaurus/preset-classic').Options} */
      ({
        docs: {
          sidebarPath: './sidebars.js',
          routeBasePath: 'docs',
          editUrl:
            'https://github.com/Great-Stone-Kong/kong-ai-gateway-workshop/tree/main/website/',
        },
        blog: false,
        theme: {
          customCss: './src/css/custom.css',
        },
      }),
    ],
  ],

  themeConfig:
    /** @type {import('@docusaurus/preset-classic').ThemeConfig} */
    ({
      image: 'img/docusaurus-social-card.jpg',
      colorMode: {
        respectPrefersColorScheme: true,
      },
      navbar: {
        title: 'Kong AI Gateway Workshop',
        logo: {
          alt: 'Kong AI Gateway Workshop',
          src: 'img/logo.svg',
        },
        items: [
          {
            type: 'docSidebar',
            sidebarId: 'workshopSidebar',
            position: 'left',
            label: '실습',
          },
          {
            type: 'doc',
            docId: 'slides',
            position: 'left',
            label: '슬라이드',
          },
          {
            type: 'localeDropdown',
            position: 'right',
          },
          {
            href: 'https://github.com/Great-Stone-Kong/kong-ai-gateway-workshop',
            label: 'GitHub',
            position: 'right',
          },
        ],
      },
      footer: {
        style: 'dark',
        links: [
          {
            title: 'Docs',
            items: [
              {label: '소개', to: '/docs/intro'},
              {label: 'Scene 0', to: '/docs/scene-0-orientation'},
              {label: '슬라이드', to: '/docs/slides'},
            ],
          },
          {
            title: 'More',
            items: [
              {
                label: 'GitHub',
                href: 'https://github.com/Great-Stone-Kong/kong-ai-gateway-workshop',
              },
              {
                label: 'Operator Terraform',
                href: 'https://github.com/Great-Stone-Kong/kong-ai-gateway-workshop/tree/main/terraform',
              },
            ],
          },
        ],
        copyright: `Copyright © ${new Date().getFullYear()} Great-Stone-Kong. Built with Docusaurus.`,
      },
      prism: {
        theme: prismThemes.github,
        darkTheme: prismThemes.dracula,
        additionalLanguages: ['bash', 'json', 'yaml'],
      },
    }),
};

export default config;
