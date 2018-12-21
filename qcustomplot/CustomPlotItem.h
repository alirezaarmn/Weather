#ifndef CUSTOMPLOTITEM_H
#define CUSTOMPLOTITEM_H

#pragma once

#include <QtQuick>
#include "qcustomplot/qcustomplot.h"

class CustomPlotItem : public QQuickPaintedItem
{
    Q_OBJECT

    Q_PROPERTY(QColor colorBackground READ getColorBackground WRITE setColorBackground NOTIFY colorBackgroundChanged)

Q_SIGNALS:
    void colorBackgroundChanged(QColor author);

public:
    CustomPlotItem( QQuickItem* parent = nullptr );
    virtual ~CustomPlotItem();

    void paint( QPainter* painter );

    QColor getColorBackground();

    Q_INVOKABLE void initCustomPlot();
    Q_INVOKABLE void setPlotData(QString time, QVector<double> minTemp, QVector<double> maxTemp);
    Q_INVOKABLE void setVisiblity(bool value);

private:
    QCustomPlot* m_CustomPlot;
    QColor _colorBackground;
    int m_minGraphIndex = 0, m_maxGraphIndex = 1;

    void setColorBackground(QColor color);
    void resetPlot();

private slots:
    void onCustomReplot();
    void updateCustomPlotSize();
    void setBackground(QColor color);

};
#endif // CUSTOMPLOTITEM_H
