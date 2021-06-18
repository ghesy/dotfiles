#define PYWAL
static const char *colors[SchemeLast][2] = {{
    /*                fg         bg      */
    [SchemeNorm] = {{ "{color2}", "{background}" }},
    [SchemeSel]  = {{ "{color14}", "{background}" }},
    [SchemeSelHighlight]  = {{ "{color14}", "{background}" }},
    [SchemeNormHighlight] = {{ "{color2}", "{background}" }},
    [SchemeOut] = {{ "{color2}", "{background}" }},
}};
