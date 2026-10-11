import mermaid from 'mermaid';

export function initializeDiagrams(figures) {
  const root = document.documentElement;
  const sources = [...figures].map(figure => ({
    figure,
    source: figure.querySelector('.mermaid-source code').textContent,
    output: figure.querySelector('.mermaid-output'),
    details: figure.querySelector('.mermaid-source'),
  }));
  let revision = 0;
  let queue = Promise.resolve();

  function render() {
    const requested = ++revision;
    // Mermaid has one shared configuration. Serialize updates so a theme change
    // cannot reconfigure diagrams while the previous render is still running.
    queue = queue.then(async () => {
      if (requested !== revision) return;
      const style = getComputedStyle(root);
      const color = name => style.getPropertyValue(name).trim();
      mermaid.initialize({
        startOnLoad: false,
        securityLevel: 'strict',
        suppressErrorRendering: true,
        htmlLabels: false,
        flowchart: { htmlLabels: false },
        theme: 'base',
        themeVariables: {
          darkMode: root.dataset.theme === 'dark',
          fontFamily: 'system-ui, sans-serif',
          background: color('--panel'),
          primaryColor: color('--panel-2'),
          primaryBorderColor: color('--mint'),
          primaryTextColor: color('--text'),
          secondaryColor: color('--soft'),
          tertiaryColor: color('--panel'),
          lineColor: color('--muted'),
          edgeLabelBackground: color('--panel'),
        },
      });
      for (const { figure, source, output, details } of sources) {
        if (requested !== revision) return;
        try {
          const { svg } = await mermaid.render(`${figure.dataset.mermaid}-${requested}`, source);
          if (requested !== revision) return;
          output.innerHTML = svg; // Mermaid's strict mode sanitizes the SVG.
          const image = output.querySelector('svg');
          image.setAttribute('role', 'img');
          if (!image.hasAttribute('aria-labelledby')) image.setAttribute('aria-label', 'Code flow diagram');
          // Preserve readable labels in wide diagrams. Their container scrolls
          // on small screens; narrow diagrams still fit the available space.
          image.style.setProperty('--diagram-width', `${Math.min(640, image.viewBox.baseVal.width)}px`);
          output.hidden = false;
          if (!figure.dataset.rendered) details.open = false;
          figure.dataset.rendered = 'true';
        } catch {
          // The page text and original diagram source remain available.
          details.open = true;
        }
      }
    }).catch(() => {
      for (const { details } of sources) details.open = true;
    });
    return queue;
  }

  const observer = new MutationObserver(render);
  observer.observe(root, { attributes: true, attributeFilter: ['data-theme'] });
  return render();
}
