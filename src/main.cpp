#include "dashboarddatacontroller.h"

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
        if (qEnvironmentVariableIsEmpty("QT_QPA_EGLFS_PHYSICAL_WIDTH"))
            qputenv("QT_QPA_EGLFS_PHYSICAL_WIDTH", QByteArray("154"));
        if (qEnvironmentVariableIsEmpty("QT_QPA_EGLFS_PHYSICAL_HEIGHT"))
            qputenv("QT_QPA_EGLFS_PHYSICAL_HEIGHT", QByteArray("90"));

#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
        QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
    }
    qputenv("QT_QPA_EGLFS_ALWAYS_SET_MODE", "1");
    qputenv("QT_QPA_EGLFS_FORCEVSYNC", "1");
    qputenv("QT_QPA_EGLFS_HIDECURSOR", "1");

    QGuiApplication app(argc, argv);
    QFontDatabase::addApplicationFont(":/assets/fonts/Venera-700.otf");

    DashboardDataController dashboardController;

    bool panelHeightOk = false;
    int physicalPanelHeight = qEnvironmentVariableIntValue("EIGP_PANEL_HEIGHT", &panelHeightOk);
    if (!panelHeightOk || physicalPanelHeight <= 0)
        physicalPanelHeight = 600;

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("dashboardController", &dashboardController);
    engine.rootContext()->setContextProperty("physicalPanelHeight", physicalPanelHeight);
    const QUrl url(QStringLiteral("qrc:/qml/main.qml"));
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
