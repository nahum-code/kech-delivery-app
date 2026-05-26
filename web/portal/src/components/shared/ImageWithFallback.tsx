import Image from "next/image";
import React, { useMemo, useState } from "react";

const ERROR_IMG_SRC =
  "data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iODgiIGhlaWdodD0iODgiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgc3Ryb2tlPSIjMDAwIiBzdHJva2UtbGluZWpvaW49InJvdW5kIiBvcGFjaXR5PSIuMyIgZmlsbD0ibm9uZSIgc3Ryb2tlLXdpZHRoPSIzLjciPjxyZWN0IHg9IjE2IiB5PSIxNiIgd2lkdGg9IjU2IiBoZWlnaHQ9IjU2IiByeD0iNiIvPjxwYXRoIGQ9Im0xNiA1OCAxNi0xOCAzMiAzMiIvPjxjaXJjbGUgY3g9IjUzIiBjeT0iMzUiIHI9IjciLz48L3N2Zz4KCg==";

type ImageWithFallbackProps = {
  src?: string;
  alt?: string;
  className?: string;
  style?: React.CSSProperties;
  width?: number | `${number}`;
  height?: number | `${number}`;
};

export function ImageWithFallback(props: ImageWithFallbackProps) {
  const [didError, setDidError] = useState(false);

  const handleError = () => {
    setDidError(true);
  };

  const { src, alt = "", style, className, width, height } = props;

  const normalizedWidth = useMemo(() => {
    if (typeof width === "number") return width;
    if (typeof width === "string" && width.trim() !== "") return Number(width);
    return undefined;
  }, [width]);

  const normalizedHeight = useMemo(() => {
    if (typeof height === "number") return height;
    if (typeof height === "string" && height.trim() !== "") return Number(height);
    return undefined;
  }, [height]);

  const useFixedSize =
    Number.isFinite(normalizedWidth) && Number.isFinite(normalizedHeight);

  const fallbackAlt = "Error loading image";
  const wrapperClass = `relative inline-block bg-gray-100 text-center align-middle ${className ?? ""}`;

  if (didError) {
    return (
      <div className={wrapperClass} style={style}>
        <div className="flex items-center justify-center w-full h-full">
          {useFixedSize ? (
            <Image
              src={ERROR_IMG_SRC}
              alt={fallbackAlt}
              width={normalizedWidth}
              height={normalizedHeight}
              unoptimized
            />
          ) : (
            <div className="relative h-full w-full min-h-12 min-w-12">
              <Image
                src={ERROR_IMG_SRC}
                alt={fallbackAlt}
                fill
                sizes="100vw"
                className="object-contain"
                unoptimized
              />
            </div>
          )}
        </div>
      </div>
    );
  }

  return (
    <div className={wrapperClass} style={style}>
      <div className="flex items-center justify-center w-full h-full">
        {useFixedSize ? (
          <Image
            src={src || ERROR_IMG_SRC}
            alt={alt}
            width={normalizedWidth}
            height={normalizedHeight}
            onError={handleError}
            unoptimized
          />
        ) : (
          <div className="relative h-full w-full min-h-12 min-w-12">
            <Image
              src={src || ERROR_IMG_SRC}
              alt={alt}
              fill
              sizes="100vw"
              className="object-contain"
              onError={handleError}
              unoptimized
            />
          </div>
        )}
      </div>
    </div>
  );
}
