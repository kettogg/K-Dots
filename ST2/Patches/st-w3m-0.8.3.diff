From 69cffc587b54b0a9cd81adb87abad8e526d5b25b Mon Sep 17 00:00:00 2001
From: "Avi Halachmi (:avih)" <avihpit@yahoo.com>
Date: Thu, 4 Jun 2020 17:35:08 +0300
Subject: [PATCH] support w3m images

w3m images are a hack which renders on top of the terminal's drawable,
which didn't work in st because when using double buffering, the front
buffer (on which w3m draws its images) is ignored, and st draws only
on the back buffer, which is then copied to the front buffer.

There's a patch to make it work at the FAQ already, but that patch
canceles double-buffering, which can have negative side effects on
some cases such as flickering.

This patch achieves the same goal but instead of canceling the double
buffer it first copies the front buffer to the back buffer.

This has the same issues as the FAQ patch in that the cursor line is
deleted at the image (because st renders always full lines), but
otherwise it's simpler and does keeps double buffering.
---
 x.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/x.c b/x.c
index e5f1737..b6ae162 100644
--- a/x.c
+++ b/x.c
@@ -1594,6 +1594,8 @@ xsettitle(char *p)
 int
 xstartdraw(void)
 {
+	if (IS_SET(MODE_VISIBLE))
+		XCopyArea(xw.dpy, xw.win, xw.buf, dc.gc, 0, 0, win.w, win.h, 0, 0);
 	return IS_SET(MODE_VISIBLE);
 }
 

base-commit: 43a395ae91f7d67ce694e65edeaa7bbc720dd027
-- 
2.17.1

