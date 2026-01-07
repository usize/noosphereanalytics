#!/bin/bash

# Blog linker script
# Generates index.html for blog posts
# Run: ./link.sh

BLOG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
POSTS_DIR="$BLOG_DIR/posts"
INDEX_FILE="$BLOG_DIR/index.html"

# Start building the index
cat > "$INDEX_FILE" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width,initial-scale=1.0">
  <title>Noosphere Analytics Blog</title>
  <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;500&display=swap" rel="stylesheet">
  <style>
    *{box-sizing:border-box}
    body{margin:0;font-family:'Roboto',sans-serif;background:#f4f4f9;color:#333}
    img{max-width:100%;height:auto;display:block}
    a{color:#0062cc;text-decoration:none}
    a:hover{text-decoration:underline}
    h1,h2,h3{margin:0;font-weight:500}
    h2{font-size:2rem}
    .blog-header{padding:60px 20px 20px;text-align:center;background:#fff}
    .blog-header h1{font-size:2.5rem;color:#222;margin-bottom:10px}
    .posts-container{max-width:800px;margin:0 auto;padding:0 20px 60px}
    .post-card{background:#fff;border:1px solid #e0e0e0;border-radius:8px;padding:24px;margin-bottom:30px;text-align:left;box-shadow:0 2px 6px rgba(0,0,0,0.05)}
    .post-card h3{font-size:1.3rem;margin-bottom:8px;color:#222}
    .post-meta{font-size:.9rem;color:#666;margin-bottom:16px}
    .post-excerpt{font-size:.95rem;color:#555;line-height:1.6;margin-bottom:16px}
    ..post-readmore{font-weight:500;color:#0062cc}
    .logo{width:150px;margin:20px auto 10px;display:block}
    .blog-nav{text-align:center;margin:20px 0}
    .blog-nav a{display:inline-block;padding:8px 16px;background:#0062cc;color:#fff;border-radius:4px;font-weight:500;font-size:.9em}
    .blog-nav a:hover{background:#004999;text-decoration:none}
    footer{margin:40px 0 20px;font-size:.9rem;color:#777;text-align:center}
  </style>
</head>
<body>

<!-- Logo -->
<img src="../logo.png" alt="Noosphere Analytics Logo" class="logo">
<br/>
<br/>

<main class="posts-container">
EOF

# Add sections for each post
for post_dir in "$POSTS_DIR"/*; do
    if [ -d "$post_dir" ]; then
        # Extract directory name as slug
        slug=$(basename "$post_dir")
        
        # Extract title from index.html if it exists
        index_file="$post_dir/index.html"
        if [ -f "$index_file" ]; then
            # Try to extract title tag content
            title=$(grep -o '<title>.*</title>' "$index_file" | sed 's/<title>//;s/<\/title>//;s/.*-\s*//' | head -1)
            
            # If no title in tag, try to get first h1 or use slug
            if [ -z "$title" ]; then
                title=$(grep -o '<h1>.*</h1>' "$index_file" | sed 's/<h1>//;s/<\/h1>//' | head -1)
            fi
            
            if [ -z "$title" ]; then
                title=$(echo "$slug" | sed 's/-/ /g' | sed 's/\b\w/\u&/g')
            fi
        else
            title=$(echo "$slug" | sed 's/-/ /g' | sed 's/\b\w/\u&/g')
        fi
        
        # Get creation date from directory modification time or first publish date
        post_date=$(date -r "$(stat -f "%m" "$post_dir" 2>/dev/null || stat -c "%Y" "$post_dir" 2>/dev/null)" "+%B %d, %Y")
        
        # Extract excerpt from meta description or first paragraph
        excerpt=""
        if [ -f "$index_file" ]; then
            # Try to get meta description
            excerpt=$(grep -o '<meta name="description" content=".*">' "$index_file" | sed 's/.*content="//;s/"//')
            
            # If no meta description, get first paragraph content
            if [ -z "$excerpt" ]; then
                excerpt=$(grep -o '<p>.*</p>' "$index_file" | sed 's/<p>//;s/<\/p>//' | head -1)
                
                # Remove HTML tags and limit length
                excerpt=$(echo "$excerpt" | sed 's/<[^>]*>//g' | head -c 150)
                
                if [ ${#excerpt} -ge 150 ]; then
                    excerpt="${excerpt}..."
                fi
            fi
        fi
        
        if [ -z "$excerpt" ]; then
            excerpt="Read more about $title"
        fi
        
        # Add post card to index
        cat >> "$INDEX_FILE" << EOF
  <article class="post-card">
    <h3><a href="posts/$slug/index.html" class="post-readmore">$title</a></h3>
    <div class="post-meta">Published on $post_date</div>
    <div class="post-excerpt">$excerpt</div>
  </article>
EOF
        
    fi
done

# Close the HTML
cat >> "$INDEX_FILE" << EOF
</main>

<footer>
  <a href="../index.html">← Back to main site</a>
</footer>

</body>
</html>
EOF

echo "Blog index generated: $INDEX_FILE"
