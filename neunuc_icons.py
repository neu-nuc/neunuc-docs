import os, re
from markdown.extensions import Extension
from markdown.inlinepatterns import InlineProcessor
from xml.etree import ElementTree as ET

ICONS_DIR = os.path.join(os.path.dirname(__file__), 'docs', 'overrides', '.icons')

class IconInlineProcessor(InlineProcessor):
    def handleMatch(self, m, data):
        name = m.group('name')
        icon_path = os.path.join(ICONS_DIR, f'{name}.svg')
        if not os.path.exists(icon_path):
            return None, m.start(), m.end()
        with open(icon_path, 'r', encoding='utf-8') as f:
            svg_text = f.read().strip()
        # Inject inline style and strip namespace so ElementTree doesn't mangle tags
        svg_text = re.sub(
            r'<svg\s+',
            '<svg style="width:1.2em;height:1.2em;vertical-align:middle;display:inline-block;" ',
            svg_text,
            count=1
        )
        svg_text = re.sub(r'\s+xmlns="[^"]+"', '', svg_text, count=1)
        # Wrap in span for markdown safety
        span = ET.Element('span')
        span.set('class', 'neunuc-icon')
        try:
            svg_el = ET.fromstring(svg_text)
        except ET.ParseError:
            return None, m.start(), m.end()
        span.append(svg_el)
        return span, m.start(), m.end()

class NeunucIconsExtension(Extension):
    def extendMarkdown(self, md):
        pattern = r"(?<!\w):(?P<name>[a-z0-9_-]+):(?!\w)"
        md.inlinePatterns.register(IconInlineProcessor(pattern, md), 'neunuc_icon', 175)

def makeExtension(**kwargs):
    return NeunucIconsExtension(**kwargs)
