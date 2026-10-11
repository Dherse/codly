const escape = source => source.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;').replaceAll('"', '&quot;');

// Keep the authored source readable before JavaScript loads, when it is disabled,
// or if rendering fails. The diagram runtime collapses it only after success.
export function mermaidFence(source, id) {
  return `<figure class="mermaid-diagram" data-mermaid="diagram-${id}"><div class="mermaid-output" role="region" aria-label="Diagram" tabindex="0" hidden></div><details class="mermaid-source" open><summary>Diagram source</summary><pre><code>${escape(source)}</code></pre></details></figure>`;
}
