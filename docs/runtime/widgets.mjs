// Shared by the Markdown build and browser so defaults and live values agree.
const units = new Set(['', 'pt', 'mm', 'cm', 'in', 'em', 'ex', '%', 'deg', 'rad', 'fr']);
const reserved = new Set('let set show if else for in while break continue return import include as and or not true false none auto context'.split(' '));
const fail = message => { throw new Error(`Widgets: ${message}`); };
const code = value => typeof value === 'string' && value.trim().length > 0 && value.length <= 2000;
const label = value => typeof value === 'string' && value.trim().length > 0;

export function sliderNumber(widget, value) {
  if (typeof value !== 'string' || (widget.unit && !value.endsWith(widget.unit))) fail(`${widget.name}: expected a ${widget.unit || 'unitless'} slider value`);
  const number = widget.unit ? value.slice(0, -widget.unit.length) : value;
  if (!/^-?(?:\d+(?:\.\d*)?|\.\d+)$/.test(number)) fail(`${widget.name}: invalid numeric value`);
  const result = Number(number);
  const steps = (result - widget.min) / widget.step;
  if (!Number.isFinite(result) || result < widget.min || result > widget.max || Math.abs(steps - Math.round(steps)) > 1e-7) fail(`${widget.name}: value must be within its range and on a step`);
  return result;
}

export function validateWidgets(input) {
  if (!Array.isArray(input) || input.length > 20) fail('expected an array of at most 20 controls');
  const names = new Set();
  return input.map(item => {
    if (!item || typeof item !== 'object') fail('each control must be an object');
    const w = { ...item };
    if (typeof w.name !== 'string' || !/^[\p{ID_Start}_][\p{ID_Continue}-]*$/u.test(w.name) || reserved.has(w.name) || names.has(w.name)) fail(`invalid or duplicate variable name: ${w.name}`);
    names.add(w.name);
    if (!label(w.label)) fail(`${w.name}: a label is required`);
    if (!code(w.default)) fail(`${w.name}: default must be a scalar containing Typst code`);
    if (w.type === 'slider') {
      w.unit ??= '';
      w.step ??= 1;
      if (!units.has(w.unit) || ![w.min, w.max, w.step].every(Number.isFinite) || w.min >= w.max || w.step <= 0) fail(`${w.name}: invalid slider bounds, step, or unit`);
      sliderNumber(w, w.default);
    } else if (w.type === 'switch') {
      if (!['true', 'false'].includes(w.default)) fail(`${w.name}: switch default must be "true" or "false"`);
    } else if (w.type === 'select') {
      if (!Array.isArray(w.options) || !w.options.length || !w.options.every(option => option && label(option.label) && code(option.value))) fail(`${w.name}: options need labels and Typst code values`);
      if (new Set(w.options.map(option => option.value)).size !== w.options.length) fail(`${w.name}: duplicate option values`);
      if (!w.options.some(option => option.value === w.default)) fail(`${w.name}: default must match an option`);
    } else fail(`${w.name}: unknown control type ${w.type}`);
    return w;
  });
}

export function widgetDefaults(widgets) {
  return Object.fromEntries(widgets.map(widget => [widget.name, widget.default]));
}

export function exampleSource(body, widgets = [], values = widgetDefaults(widgets)) {
  const bindings = widgets.map(widget => {
    const value = values[widget.name];
    if (!code(value)) fail(`${widget.name}: a Typst expression is required`);
    if (widget.type === 'slider') sliderNumber(widget, value);
    if (widget.type === 'switch' && !['true', 'false'].includes(value)) fail(`${widget.name}: expected true or false`);
    if (widget.type === 'select' && !widget.options.some(option => option.value === value)) fail(`${widget.name}: unknown option`);
    // Keep expressions as Typst code, including quotes when a string is wanted.
    return `#let ${widget.name} = ${value}\n`;
  }).join('');
  return bindings ? `${bindings}\n${body}` : body;
}
