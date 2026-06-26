import { Link } from 'umi';
import styles from './CtaSection.module.css';

/**
 * 行动召唤（CTA）区域组件。
 *
 * 职责：
 * 1. 渲染“开始体验”标题和跳转链接。
 * 2. 将 umi 的 <Link> 通过 CSS 装扮成按钮样式，不引入额外的 <button> 元素。
 */
interface CtaSectionProps {
  /** 区域标题 */
  heading: string;
  /** 链接目标路径 */
  linkTo: string;
  /** 链接显示文本 */
  linkText: string;
}

export default function CtaSection({ heading, linkTo, linkText }: CtaSectionProps) {
  return (
    <section className={styles.ctaSection}>
      <h2 className={styles.heading}>{heading}</h2>
      <Link to={linkTo} className={styles.ctaButton}>
        {linkText}
      </Link>
    </section>
  );
}
