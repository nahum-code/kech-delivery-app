import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { AlertCircle } from "lucide-react";

interface ErrorStateProps {
  title?: string;
  description?: string;
  onRetry?: () => void;
}

export function ErrorState({ 
  title = "Something went wrong", 
  description = "We encountered an error loading this data. Please try again.",
  onRetry
}: ErrorStateProps) {
  return (
    <Card>
      <CardContent className="p-12">
        <div className="flex flex-col items-center justify-center text-center">
          <div className="w-16 h-16 rounded-full bg-red-50 flex items-center justify-center mb-4">
            <AlertCircle className="w-8 h-8 text-red-500" />
          </div>
          <h3 className="text-lg font-semibold text-gray-900 mb-2">{title}</h3>
          <p className="text-gray-600 mb-6 max-w-sm">{description}</p>
          {onRetry && (
            <Button 
              onClick={onRetry}
              className="bg-[#800020] hover:bg-[#600018]"
            >
              Try Again
            </Button>
          )}
        </div>
      </CardContent>
    </Card>
  );
}
