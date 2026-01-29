
{#
# Copyright (C) 2021 The Qt Company Ltd.
# Copyright (C) 2019 Luxoft Sweden AB
# Copyright (C) 2018 Pelagicore AG
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR GPL-3.0-only WITH Qt-GPL-exception-1.0
#}
{% set class = '{0}'.format(module.module_name|upperfirst) %}
{% set qml_name = (module|qml_type).split('.')[-1]|upperfirst %}
{% include 'common/generated_comment.cpp.tpl' %}
{% import 'common/qtif_macros.j2' as qtif %}

#include "{{class|lower}}.h"
#include "{{class|lower}}factory.h"
{% for interface in module.interfaces %}
#include "{{interface|lower}}.h"
{% endfor %}
#include <QtInterfaceFramework/QIfPendingReply>
#include <QQmlEngine>
#include <QDebug>
#include <QDataStream>

{{ module|begin_namespace }}

template <typename T>
QString enumToString(T enumValue)
{
    const QMetaObject *mo = qt_getEnumMetaObject(enumValue);
    int enumIdx = mo->indexOfEnumerator(qt_getEnumName(enumValue));
    return QString(mo->enumerator(enumIdx).valueToKey(enumValue));
}


/*! \internal */
QObject* {{class|lower}}_singletontype_provider(QQmlEngine*, QJSEngine*)
{
    return new {{class}}Factory();
}

/*!
    \class {{class}}
    \inmodule {{module}}

    \brief The {{class}} class holds all the enums defined in the {{module}} module.
*/
{% for enum in module.enums %}
/*!
    \enum {{class}}::{{enum}}
    {{ qtif.format_comments(enum.comment) }}

{%  for member in enum.members %}
    \value {{member}}
    {{ qtif.format_comments(member.comment) }}
{%  endfor %}
*/
{% endfor %}
{{class}}::{{class}}(QObject *parent)
    : QObject(parent)
{
}

{% for enum in module.enums %}
/*! \internal */
{%   if enum.is_flag %}
{{class}}::{{enum|flag_type}} {{class}}::to{{enum|flag_type}}(quint32 v, bool *ok)
{
    if (ok)
        *ok = true;

    return {{class}}::{{enum|flag_type}}(v);
}
{%   else %}
{{class}}::{{enum}} {{class}}::to{{enum}}(quint32 v, bool *ok)
{
    if (ok)
        *ok = true;
    switch (v) {
{% for member in enum.members %}
    case {{member.value}}: return {{member.name}};
{% endfor %}
    default:
        if (ok)
            *ok = false;
        return {{enum.members|first}};
    }
}
{%   endif %}

Q_INVOKABLE QString {{class}}::{{enum.name[0]|lower + enum.name[1:]}}ToString(int {{enum.name[0]|lower + enum.name[1:]}})
{
    return enumToString(static_cast<{{enum}}>({{enum.name[0]|lower + enum.name[1:]}}));
}
{% endfor %}
/*! \internal */
void {{class}}::registerTypes()
{
    static bool once = false;
    if (once)
        return;
    once = true;

{% for import in module.imports %}
{# All imports are provided including their imported version e.g. "Common 1.0". Because we need
   to access the Module type, we first need to split the version and then search for the name.
   See https://github.com/Pelagicore/qface/issues/87
#}
{%   set name = import.split(' ')[0] %}
{%   for mod in system.modules %}
{%     if mod.name == name %}
    {{mod.module_name|upperfirst|add_namespace_prefix(mod)}}::registerTypes();
{%     endif %}
{%   endfor %}
{% endfor %}

{% for enum in module.enums %}
    qRegisterMetaType<{{class}}::{{enum|flag_type}}>();
    qIfRegisterPendingReplyType<{{class}}::{{enum|flag_type}}>();
{%   if enum.is_flag %}
    //Workaround for https://bugreports.qt.io/browse/QTBUG-75676
    if (!QMetaType::hasRegisteredConverterFunction<{{class}}::{{enum|flag_type}}, int>())
        QMetaType::registerConverter<{{class}}::{{enum|flag_type}}, int>();
{%   endif %}
{% endfor %}
{% for struct in module.structs %}
    qRegisterMetaType<{{struct}}>();
    qIfRegisterPendingReplyType<{{struct}}>();
{% endfor %}
}

/*! \internal */
void {{class}}::registerQmlTypes(const QString& uri, int majorVersion, int minorVersion)
{
    registerTypes();
    qmlRegisterSingletonType<{{class}}>(uri.toLatin1(), majorVersion, minorVersion,
                                        "{{qml_name}}",
                                        {{class|lower}}_singletontype_provider);
{% for interface in module.interfaces %}
    {{interface}}::registerQmlTypes(uri, majorVersion, minorVersion);
{% endfor %}
}
{% for enum in module.enums %}

QDataStream &operator<<(QDataStream &out, {{class}}::{{enum|flag_type}} var)
{
    out << quint32(var);
    return out;
}

QDataStream &operator>>(QDataStream &in, {{class}}::{{enum|flag_type}} &var)
{
    bool ok;
    quint32 val;
    in >> val;
    var = {{class}}::to{{enum|flag_type}}(val, &ok);
    if (!ok)
        qWarning() << "Received an invalid enum value for type {{class}}::{{enum|flag_type}}, value =" << var;
    return in;
}
{% endfor %}

{{ module|end_namespace }}
