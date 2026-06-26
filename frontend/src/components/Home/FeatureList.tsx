import styles from './FeatureList.module.css';

/**
 * 特性列表组件。
 *
 * 职责：
 * 1. 渲染一组技术栈/功能卡片。
 * 2. 保持语义化列表结构（<ul>/<li>），便于测试和无障碍访问。
 * 3. 通过 CSS Modules 实现卡片网格、悬停动效。
 */
interface FeatureItem {
  /** 卡片图标（emoji 或字符） */
  icon: string;
  /** 卡片标题 */
  title: string;
  /** 卡片描述 */
  description: string;
}

interface FeatureListProps {
  /** 列表区域标题 */
  heading: string;
  /** 特性数据 */
  items: FeatureItem[];
}

export default function FeatureList({ heading, items }: FeatureListProps) {
  return (
    <section className={styles.featureSection}>
      <h2 className={styles.heading}>{heading}</h2>
      <ul className={styles.featureList}>
        {items.map((item, index) => (
          <li key={index} className={styles.featureCard}>
            <span className={styles.icon}>{item.icon}</span>
            <strong className={styles.cardTitle}>{item.title}</strong>
            <span className={styles.cardDesc}>{item.description}</span>
          </li>
        ))}
      </ul>
    </section>
  );
}
