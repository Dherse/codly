export const externalLinkIcon = '<svg class="external-link-icon" viewBox="0 0 16 16" aria-hidden="true" focusable="false"><path d="M9 2h5v5M14 2 7 9M6 3H3a1 1 0 0 0-1 1v9a1 1 0 0 0 1 1h9a1 1 0 0 0 1-1v-3"/></svg>';

const attribute = name => new RegExp(`\\s+${name}\\s*=\\s*(?:"([^"]*)"|'([^']*)'|([^\\s>]+))`, 'i');
const value = (tag, name) => tag.match(attribute(name))?.slice(1).find(part => part !== undefined);
const escape = text => text.replaceAll('&', '&amp;').replaceAll('"', '&quot;').replaceAll('<', '&lt;');
function set(tag, name, text) {
  const replacement = ` ${name}="${escape(text)}"`;
  if (attribute(name).test(tag)) return tag.replace(attribute(name), () => replacement);
  return tag.slice(0, -1) + replacement + '>';
}

export function configureLinks(html) {
  return html.replace(/(<a\b[^>]*>)([\s\S]*?)(<\/a\s*>)/gi, (match, tag, content, end) => {
    const href = value(tag, 'href');
    if (!href) return match;
    if (!/^(?:https?:)?\/\//i.test(href)) return tag.replace(attribute('target'), '') + content + end;
    tag = set(tag, 'target', '_blank');
    const rel = new Set((value(tag, 'rel') || '').split(/\s+/).filter(Boolean));
    rel.add('noopener');
    rel.add('noreferrer');
    tag = set(tag, 'rel', [...rel].join(' '));
    if (!value(tag, 'title')) tag = set(tag, 'title', 'Opens in a new tab');
    if (!content.includes('class="external-link-icon"')) content += externalLinkIcon;
    return tag + content + end;
  });
}
