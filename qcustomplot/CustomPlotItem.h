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
    Q_INVOKABLE void setPlotData(QVector<double> xAxis, QVector<double> yAxis);

protected:
    void routeMouseEvents( QMouseEvent* event );

    virtual void mousePressEvent( QMouseEvent* event );
    virtual void mouseReleaseEvent( QMouseEvent* event );
    virtual void mouseMoveEvent( QMouseEvent* event );
    virtual void mouseDoubleClickEvent( QMouseEvent* event );


private:
    QCustomPlot*         m_CustomPlot;
    QColor _colorBackground;
    int m_minGraphIndex, m_maxGraphIndex;

    void setColorBackground(QColor color);

private slots:
    void graphClicked( QCPAbstractPlottable* plottable );
    void onCustomReplot();
    void updateCustomPlotSize();
    void setBackground(QColor color);

};
#endif // CUSTOMPLOTITEM_H
