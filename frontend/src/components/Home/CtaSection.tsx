import { Link } from 'umi';
import styles from './CtaSection.module.css';

interface CtaSectionProps {
    heading: string;
    linkTo: string;
    linkText: string;
    onButtonClick?: (e: React.MouseEvent<HTMLAnchorElement>) => void;  // ← 接收事件对象
}

export default function CtaSection({
                                       heading,
                                       linkTo,
                                       linkText,
                                       onButtonClick
                                   }: CtaSectionProps) {
    const handleClick = (e: React.MouseEvent<HTMLAnchorElement>) => {
        if (onButtonClick) {
            onButtonClick(e);  // 传递事件对象给父组件
        }
    };

    return (
        <section className={styles.ctaSection}>
            <h2 className={styles.heading}>{heading}</h2>
            <Link
                to={linkTo}
                className={styles.ctaButton}
                onClick={handleClick}
            >
                {linkText}
            </Link>
        </section>
    );
}
