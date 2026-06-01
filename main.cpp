#include "dashboardserialcontroller.h"

#include <QCursor>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QDebug>
#include <QFontDatabase>

int main(int argc, char *argv[])
{
    qputenv("QT_IM_MODULE", QByteArray("qtvirtualkeyboard"));

    if (qEnvironmentVariableIsEmpty("QTGLESSTREAM_DISPLAY")) {
        qputenv("QT_QPA_EGLFS_PHYSICAL_WIDTH", QByteArray("154"));
        qputenv("QT_QPA_EGLFS_PHYSICAL_HEIGHT", QByteArray("86"));

#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
        QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
    }
    qputenv("QT_QPA_EGLFS_ALWAYS_SET_MODE", "1");
    qputenv("QT_QPA_EGLFS_FORCEVSYNC", "1");
    qputenv("QT_QPA_EGLFS_HIDECURSOR", "1");
    QGuiApplication app(argc, argv);
    QFontDatabase::addApplicationFont(":/Venera-700.otf");
    QGuiApplication::setOverrideCursor(QCursor(Qt::BlankCursor));
    DashboardSerialController serialController;

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("serialController", &serialController);
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlEngine::warnings,
        &app, [](const QList<QQmlError> &warnings) {
            for (const QQmlError &warning : warnings)
                qWarning().noquote() << warning.toString();
        });
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
        &app, [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
