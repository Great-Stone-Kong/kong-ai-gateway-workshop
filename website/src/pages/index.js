import clsx from 'clsx';
import Link from '@docusaurus/Link';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import Layout from '@theme/Layout';
import Heading from '@theme/Heading';

import styles from './index.module.css';

function HomepageHeader() {
  const {siteConfig, i18n} = useDocusaurusContext();
  const isKo = i18n.currentLocale === 'ko';
  return (
    <header className={clsx('hero hero--primary', styles.heroBanner)}>
      <div className="container">
        <Heading as="h1" className="hero__title">
          {siteConfig.title}
        </Heading>
        <p className="hero__subtitle">{siteConfig.tagline}</p>
        <div className={styles.buttons}>
          <Link className="button button--secondary button--lg" to="/docs/intro">
            {isKo ? '실습 시작하기' : 'Start the workshop'}
          </Link>
        </div>
      </div>
    </header>
  );
}

export default function Home() {
  const {siteConfig, i18n} = useDocusaurusContext();
  const isKo = i18n.currentLocale === 'ko';
  return (
    <Layout
      title={isKo ? '홈' : 'Home'}
      description={siteConfig.tagline}>
      <HomepageHeader />
      <main>
        <section className={styles.features}>
          <div className="container">
            <p>
              {isKo
                ? 'Kong Konnect Serverless에서 API Gateway와 AI Proxy를 구성하고, 공유 Workshop LLM 허브에 연결합니다.'
                : 'Build API Gateway and AI Proxy on Kong Konnect Serverless, then connect to the shared Workshop LLM hub.'}
            </p>
          </div>
        </section>
      </main>
    </Layout>
  );
}
