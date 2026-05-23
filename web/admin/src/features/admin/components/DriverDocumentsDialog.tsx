"use client";

import { useEffect, useState } from "react";
import { format } from "date-fns";
import { ExternalLink, FileText } from "lucide-react";
import { toast } from "sonner";

import {
  fetchDriverDocuments,
  type DriverDocumentRecord,
  type DriverDocumentsResponse,
} from "@/services/drivers";
import { Button } from "../components/ui/button";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
} from "../components/ui/dialog";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "../components/ui/tabs";

type DriverDocumentsDialogProps = {
  userId: number | null;
  driverName: string;
  open: boolean;
  onOpenChange: (open: boolean) => void;
};

export function DriverDocumentsDialog({
  userId,
  driverName,
  open,
  onOpenChange,
}: DriverDocumentsDialogProps) {
  const [loading, setLoading] = useState(false);
  const [data, setData] = useState<DriverDocumentsResponse | null>(null);

  useEffect(() => {
    if (!open || userId == null) {
      return;
    }
    setLoading(true);
    setData(null);
    void fetchDriverDocuments(userId)
      .then(setData)
      .catch((e) => {
        toast.error(e instanceof Error ? e.message : "Failed to load documents");
        onOpenChange(false);
      })
      .finally(() => setLoading(false));
  }, [open, userId, onOpenChange]);

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle>{driverName || "Driver"} — onboarding files</DialogTitle>
        </DialogHeader>

        <Tabs defaultValue="uploaded">
          <TabsList>
            <TabsTrigger value="uploaded">Uploaded files</TabsTrigger>
          </TabsList>
          <TabsContent value="uploaded" className="mt-4">
            {loading ? (
              <p className="text-sm text-muted-foreground">Loading documents…</p>
            ) : data == null ? (
              <p className="text-sm text-muted-foreground">No data.</p>
            ) : data.documents.length === 0 ? (
              <p className="text-sm text-muted-foreground">
                No documents uploaded yet for this driver.
              </p>
            ) : (
              <div className="space-y-4">
                <p className="text-sm text-gray-600">
                  {data.documents_submitted
                    ? "All required documents submitted."
                    : `${data.documents.length} file(s) on record — review before approval.`}
                </p>
                <div className="grid gap-4 sm:grid-cols-2">
                  {data.documents.map((doc) => (
                    <DocumentPreview key={doc.document_type} doc={doc} />
                  ))}
                </div>
              </div>
            )}
          </TabsContent>
        </Tabs>
      </DialogContent>
    </Dialog>
  );
}

function DocumentPreview({ doc }: { doc: DriverDocumentRecord }) {
  const uploadedLabel = doc.uploaded_at
    ? format(new Date(doc.uploaded_at), "MMM d, yyyy HH:mm")
    : "—";

  return (
    <div className="rounded-lg border bg-white p-3 space-y-2">
      <div className="flex items-start justify-between gap-2">
        <div>
          <p className="font-medium text-sm text-gray-900">{doc.document_type_label}</p>
          <p className="text-xs text-gray-500">{uploadedLabel}</p>
        </div>
        {doc.file_url ? (
          <Button variant="outline" size="sm" asChild>
            <a href={doc.file_url} target="_blank" rel="noopener noreferrer">
              <ExternalLink className="h-3.5 w-3.5 mr-1" />
              Open
            </a>
          </Button>
        ) : null}
      </div>
      {doc.file_url && !doc.is_pdf ? (
        // eslint-disable-next-line @next/next/no-img-element
        <img
          src={doc.file_url}
          alt={doc.document_type_label}
          className="w-full max-h-48 object-contain rounded border bg-gray-50"
        />
      ) : doc.file_url && doc.is_pdf ? (
        <div className="flex items-center gap-2 text-sm text-gray-600 py-6 justify-center border rounded bg-gray-50">
          <FileText className="h-5 w-5" />
          PDF document — use Open to view
        </div>
      ) : (
        <p className="text-xs text-gray-500">File unavailable</p>
      )}
    </div>
  );
}
