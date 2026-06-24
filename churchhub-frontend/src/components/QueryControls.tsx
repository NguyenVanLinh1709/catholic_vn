"use client";

import { useState } from "react";
import { usePathname, useRouter, useSearchParams } from "next/navigation";
import { Search } from "lucide-react";
import { Input } from "./Field";
import { Button } from "./Button";
import { Pagination } from "./Pagination";

/** Search box that drives the `search` query param (resets to page 0). */
export function SearchBar({ placeholder = "Tìm theo tên nhà thờ…" }: { placeholder?: string }) {
  const router = useRouter();
  const pathname = usePathname();
  const params = useSearchParams();
  const [value, setValue] = useState(params.get("search") ?? "");

  function submit() {
    const next = new URLSearchParams(params.toString());
    if (value.trim()) next.set("search", value.trim());
    else next.delete("search");
    next.delete("page");
    router.push(`${pathname}?${next.toString()}`);
  }

  return (
    <div className="flex gap-2">
      <div className="relative flex-1">
        <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-gray-400 dark:text-gray-500" />
        <Input
          value={value}
          onChange={(e) => setValue(e.target.value)}
          onKeyDown={(e) => {
            if (e.key === "Enter") submit();
          }}
          placeholder={placeholder}
          className="pl-9"
          aria-label="Tìm kiếm"
        />
      </div>
      <Button onClick={submit}>Tìm</Button>
    </div>
  );
}

/** Pagination that drives the `page` query param. `page` is 0-based. */
export function QueryPagination({ page, totalPages }: { page: number; totalPages: number }) {
  const router = useRouter();
  const pathname = usePathname();
  const params = useSearchParams();

  function go(next: number) {
    const sp = new URLSearchParams(params.toString());
    sp.set("page", String(next));
    router.push(`${pathname}?${sp.toString()}`);
  }

  return <Pagination page={page} totalPages={totalPages} onChange={go} />;
}
