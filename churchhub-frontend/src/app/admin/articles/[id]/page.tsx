"use client";

import { useEffect, useState } from "react";
import { useParams } from "next/navigation";
import { ArticleEditor } from "@/components/ArticleEditor";
import { LoadingBlock, EmptyState } from "@/components/Feedback";
import { useToast } from "@/components/Toast";
import type { Article } from "@/lib/types";
import { getMyArticle } from "../../actions";

export default function EditArticlePage() {
  const params = useParams<{ id: string }>();
  const toast = useToast();
  const [loading, setLoading] = useState(true);
  const [article, setArticle] = useState<Article | null>(null);

  useEffect(() => {
    const id = Number(params.id);
    if (Number.isNaN(id)) {
      setLoading(false);
      return;
    }
    getMyArticle(id).then((res) => {
      if (res.ok) setArticle(res.data);
      else toast.error(res.message);
      setLoading(false);
    });
  }, [params.id, toast]);

  if (loading) return <LoadingBlock />;
  if (!article) return <EmptyState title="Không tìm thấy bài viết" />;
  return <ArticleEditor article={article} />;
}
