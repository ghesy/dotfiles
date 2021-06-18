#define PYWAL
static const char *colors[SchemeLast][2] = {{
    /*                fg         bg      */
    [SchemeNorm] = {{ "{color2}", "{color0}" }},
    [SchemeSel]  = {{ "{color14}", "{color0}" }},
    [SchemeSelHighlight]  = {{ "{color14}", "{color0}" }},
    [SchemeNormHighlight] = {{ "{color2}", "{color0}" }},
    [SchemeOut] = {{ "{color0}", "{color14}" }},
}};
