import styles from './HeroSection.module.css';

/**
 * Hero 区域组件。
 *
 * 职责：
 * 1. 展示页面主标题与项目简介。
 * 2. 通过渐变背景和大字号排版营造首屏视觉焦点。
 */
interface HeroSectionProps {
  /** 页面主标题 */
  title: string;
  /** 项目简介文本 */
  description: string;
}

export default function HeroSection({ title, description }: HeroSectionProps) {
  return (
    <section className={styles.hero}>
      <h1 className={styles.title}>{title}</h1>
      <p className={styles.description}>{description}</p>
    </section>
  );
}
