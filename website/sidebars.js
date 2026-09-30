// @ts-check

/** @type {import('@docusaurus/plugin-content-docs').SidebarsConfig} */
const sidebars = {
  workshopSidebar: [
    'intro',
    {
      type: 'category',
      label: 'Scenes',
      collapsed: false,
      items: [
        'scene-0-orientation/index',
        'scene-1-services-routes/index',
        'scene-2-plugin/index',
        'scene-3-auth/index',
        'scene-4-ai-proxy-openai/index',
        'scene-5-ai-multi-provider/index',
        'scene-6-claude-code-backend/index',
      ],
    },
    'slides',
  ],
};

export default sidebars;
