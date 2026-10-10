import { parseDocument } from 'yaml';
import { sliderNumber, validateWidgets } from '../runtime/widgets.mjs';
const escape = value => String(value).replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;').replaceAll('"', '&quot;');

export function parseWidgets(source) {
  // Keep expression scalars as text: YAML must not reinterpret Typst booleans,
  // numbers, or identifiers. Only slider metadata is converted to JS numbers.
  const document = parseDocument(source, { schema: 'failsafe', uniqueKeys: true });
  if (document.errors.length || document.warnings.length) throw document.errors[0] || document.warnings[0];
  const input = document.toJS({ maxAliasCount: 100 });
  if (Array.isArray(input)) for (const widget of input) {
    if (widget?.type !== 'slider') continue;
    for (const field of ['min', 'max', 'step']) if (Object.hasOwn(widget, field)) {
      const value = widget[field];
      widget[field] = typeof value === 'string' && value.trim() ? Number(value) : NaN;
    }
  }
  return validateWidgets(input);
}

export function renderWidgets(widgets, prefix) {
  if (!widgets.length) return '';
  const controls = widgets.map((widget, index) => {
    const id = `${prefix}-widget-${index}`;
    const attrs = `id="${id}" data-widget="${escape(widget.name)}"`;
    let input;
    if (widget.type === 'slider') {
      input = `<input ${attrs} type="range" min="${widget.min}" max="${widget.max}" step="${widget.step}" value="${sliderNumber(widget, widget.default)}" aria-valuetext="${escape(widget.default)}">`;
    } else if (widget.type === 'switch') {
      input = `<input ${attrs} type="checkbox" role="switch"${widget.default === 'true' ? ' checked' : ''}>`;
    } else {
      input = `<select ${attrs}>${widget.options.map(option => `<option value="${escape(option.value)}"${option.value === widget.default ? ' selected' : ''}>${escape(option.label)}</option>`).join('')}</select>`;
    }
    return `<div class="example-control"><div class="control-label"><label for="${id}">${escape(widget.label)}</label><output for="${id}">${escape(widget.default)}</output></div>${input}</div>`;
  }).join('');
  return `<fieldset class="example-controls" disabled><legend>Try the controls</legend><div class="controls-grid">${controls}</div><div class="controls-footer"><p class="hint">Adjust a value to update the source and preview. Changes stay in this tab.</p><button type="button" data-reset-widgets>Reset controls</button></div></fieldset>`;
}
