
{#
# Copyright (C) 2021 The Qt Company Ltd.
# Copyright (C) 2019 Luxoft Sweden AB
# Copyright (C) 2018 Pelagicore AG
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR GPL-3.0-only WITH Qt-GPL-exception-1.0
#}
{% set exportsymbol = 'Q_{0}_EXPORT'.format(module|upper|replace('.', '_')) %}
{% set class = '{0}'.format(module.module_name|upperfirst) %}
{% set oncedefine = '{0}_H_'.format(class|upper) %}
{% include 'common/generated_comment.cpp.tpl' %}

#ifndef {{oncedefine}}
#define {{oncedefine}}

{% if module.tags.config.module %}
#include <{{module.tags.config.module}}/{{module.module_name|lower}}global.h>
{% else %}
#include "{{module.module_name|lower}}global.h"
{% endif %}

{% for import in module.imports %}
{# All imports are provided including their imported version e.g. "Common 1.0". Because we need
   to access the Module type, we first need to split the version and then search for the name.
   See https://github.com/Pelagicore/qface/issues/87
#}
{%   set name = import.split(' ')[0] %}
{%   for mod in system.modules %}
{%     if mod.name == name %}
#include <{{mod.module_name|lower}}.h>
{%     endif %}
{%   endfor %}
{% endfor %}

#include <QtCore/QObject>

{{ module|begin_namespace }}

class {{exportsymbol}} {{class}} : public QObject
{
    Q_OBJECT

public:
    {{class}}(QObject *parent=nullptr);

{% for enum in module.enums %}
    enum {{enum}} {
        {% for member in enum.members %}
        {{member.name}} = {{member.value}},
        {% endfor %}
    };
{% if enum.is_flag %}
    Q_DECLARE_FLAGS({{enum|flag_type}}, {{enum}})
    Q_FLAG({{enum|flag_type}})
{% else %}
    Q_ENUM({{enum}})
{% endif %}
    static {{enum|flag_type}} to{{enum|flag_type}}(quint32 v, bool *ok);
    Q_INVOKABLE QString {{enum.name[0]|lower + enum.name[1:]}}ToString(int {{enum.name[0]|lower + enum.name[1:]}});
{% endfor %}

    static void registerTypes();
    static void registerQmlTypes(const QString& uri = QStringLiteral("{{module|qml_type}}"), int majorVersion = {{module.majorVersion}}, int minorVersion = {{module.minorVersion}});
};

{% for enum in module.enums %}
{{exportsymbol}} QDataStream &operator<<(QDataStream &out, {{class}}::{{enum|flag_type}} var);
{{exportsymbol}} QDataStream &operator>>(QDataStream &in, {{class}}::{{enum|flag_type}} &var);
{% endfor %}

{{ module|end_namespace }}

#endif // {{oncedefine}}

